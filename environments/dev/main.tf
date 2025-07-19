provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket = "devops-terraform-state-bucket-abhishek"
    key    = "environments/dev/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
  }
}

module "vpc" {
  source                = "../../modules/vpc"
  vpc_cidr              = var.vpc_cidr
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
  source      = "../../modules/ec2"
  project     = "myapp"
  environment = var.env
  component   = "web"
  vpc_id = module.vpc.vpc_id
  ami_id                         = local.al2_ami
  instance_type                  = var.instance_type
  subnet_id                      = module.vpc.public_subnet_ids[0]
  associate_public_ip_address    = true
  key_name                       = "myapp-dev-key"
  public_key = file("~/.ssh/id_rsa.pub")
  user_data                      = file("${path.module}/scripts/bootstrap.sh")
  app_port  = 80
}

module "ecs_fargate" {
  source = "../../modules/ecs_fargate"

  project           = "myapp"
  environment       = var.env

  # These values are only used during initial bootstrapping or optional full infra deployment
  container_image   = "123456789012.dkr.ecr.ap-south-1.amazonaws.com/nodejs-app:latest"
  container_port    = 80
  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets
  target_group_arn  = module.alb.target_group_arn
  desired_count     = 2

  # Only needed if you want to use Terraform to create task def and service
  create_task_definition = false
  create_service         = false

  count = var.enable_ecs_fargate ? 1 : 0
}
