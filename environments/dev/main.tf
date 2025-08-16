provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket  = "devops-terraform-state-bucket-abhishek"
    key     = "environments/dev/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

resource "aws_key_pair" "main" {
  key_name   = "myapp-dev-key"
  public_key = var.public_key
}


module "vpc" {
  source               = "../../modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  env                  = var.env
}

data "aws_ssm_parameter" "al2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

locals {
  al2_ami = data.aws_ssm_parameter.al2_ami.value
}

module "web_ec2" {
  source                      = "../../modules/ec2"
  project                     = "myapp"
  environment                 = var.env
  component                   = "web"
  vpc_id                      = module.vpc.vpc_id
  ami_id                      = local.al2_ami
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnet_ids[0]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main.key_name
  public_key                  = var.public_key
  user_data                   = file("${path.module}/scripts/bootstrap.sh")
  app_port                    = 80
  count                       = var.enable_ec2 ? 1 : 0
}

module "bastion_ec2" {
  source                      = "../../modules/ec2"
  project                     = "myapp"
  environment                 = var.env
  component                   = "bastion"
  vpc_id                      = module.vpc.vpc_id
  ami_id                      = local.al2_ami
  instance_type               = "t3.micro" # or your preferred type
  subnet_id                   = module.vpc.public_subnet_ids[0]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main.key_name
  public_key                  = var.public_key
  user_data                   = "" # No user data for bastion
  app_port                    = 22 # SSH only
  count                       = 1
}

module "alb" {
  count             = var.enable_alb ? 1 : 0
  source            = "../../modules/alb"
  project           = "myapp"
  environment       = var.env
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  target_port       = 80
  target_type       = "ip" # Use "ip" for Fargate tasks
}

data "aws_ecs_task_definition" "from_github" {
  task_definition = "myapp-task" # this is the ECS task family name
}

module "ecs_fargate" {
  source = "../../modules/ecs_fargate"

  project               = "myapp"
  environment           = var.env
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb[0].security_group_id
  target_group_arn      = module.alb[0].target_group_arn

  task_definition_arn = data.aws_ecs_task_definition.from_github.arn
  container_name      = "myapp"
  container_port      = 80

  desired_count = 2
  count         = var.enable_ecs_fargate ? 1 : 0
}

module "eks" {
  source             = "../../modules/eks"
  create_eks         = var.create_eks
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  subnet_ids         = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
}