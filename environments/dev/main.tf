provider "aws" {
  region = "ap-south-1"
}

data "aws_eks_cluster_auth" "mycluster" {
  count = var.create_eks ? 1 : 0
  name  = var.cluster_name
}

provider "helm" {
  kubernetes = {
    host                   = var.create_eks ? module.eks.eks_cluster_endpoint : "https://dummy"
    cluster_ca_certificate = var.create_eks ? base64decode(module.eks.eks_cluster_certificate_authority_data) : ""
    token                  = var.create_eks ? data.aws_eks_cluster_auth.mycluster[0].token : ""
  }
}

terraform {
  backend "s3" {
    bucket         = "devops-terraform-state-bucket-abhishek"
    key            = "environments/dev/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
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

module "bastion_ec2" {
  source                      = "../../modules/ec2"
  project                     = "myapp"
  environment                 = var.env
  component                   = "bastion"
  vpc_id                      = module.vpc.vpc_id
  ami_id                      = local.al2_ami
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnet_ids[0]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main.key_name
  public_key                  = var.public_key
  app_port                    = 22
  # count                       = 1
  user_data = file("${path.module}/scripts/bootstrap.sh")

  ingress_cidr_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.my_ip]
      description = "SSH access to Bastion from allowed IPs"
    }
  ]

  ingress_sg_rules = []
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

  ingress_cidr_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.my_ip] # restrict app access to your IP
      description = "Allow HTTP access from my IP"
    }
  ]

  ingress_sg_rules = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = module.bastion_ec2.security_group_id
      description              = "SSH only from Bastion"
    }
  ]
}

# EC2 Bastion Host to access Private EKS
resource "aws_security_group_rule" "eks_api_from_bastion" {
  count                    = var.create_eks ? 1 : 0
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = module.bastion_ec2[0].security_group_id
  description              = "Allow EKS API access from bastion"
}

# Docker EC2 Instance to host Docker containers
module "docker_ec2" {
  source                      = "../../modules/ec2"
  project                     = "my-docker-app"
  environment                 = var.env
  component                   = "docker"
  vpc_id                      = module.vpc.vpc_id
  ami_id                      = local.al2_ami
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnet_ids[0]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main.key_name
  public_key                  = var.public_key
  app_port                    = 5000 # Flask app
  count                       = var.enable_docker_ec2 ? 1 : 0
  user_data                   = file("${path.module}/scripts/docker-ec2-bootstrap.sh")
  iam_instance_profile        = var.enable_docker_ec2 ? aws_iam_instance_profile.docker_ec2_profile[0].name : null

  ingress_cidr_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.my_ip]
      description = "Flask app access only from my IP"
    }
  ]

  ingress_sg_rules = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = module.bastion_ec2.security_group_id
      description              = "SSH only from Bastion"
    }
  ]
}

# IAM Role for Docker EC2
resource "aws_iam_role" "docker_ec2_role" {
  count = var.enable_docker_ec2 ? 1 : 0
  name  = "${var.env}-docker-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "docker_ec2_ecr_policy" {
  count = var.enable_docker_ec2 ? 1 : 0

  role       = aws_iam_role.docker_ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_instance_profile" "docker_ec2_profile" {
  count = var.enable_docker_ec2 ? 1 : 0

  name = "${var.env}-docker-ec2-profile"
  role = aws_iam_role.docker_ec2_role[0].name
}

# ALB and ECS Fargate setup
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

module "eks_addons" {
  source = "../../modules/eks-addons"

  cluster_name                           = module.eks.eks_cluster_name
  oidc_provider_arn                      = module.eks.oidc_provider_arn
  oidc_provider_url                      = module.eks.oidc_provider_url
  namespace                              = "kube-system"
  create_eks                             = var.create_eks
  eks_cluster_endpoint                   = module.eks.eks_cluster_endpoint
  eks_cluster_certificate_authority_data = module.eks.eks_cluster_certificate_authority_data
  region                                 = var.region
  vpc_id                                 = module.vpc.vpc_id
  providers = {
    helm = helm
  }
  count = var.create_eks ? 1 : 0
}