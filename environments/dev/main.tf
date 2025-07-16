provider "aws" {
  region = "ap-south-1" # or your preferred region
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
  source = "../../modules/vpc"

  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  az                 = "ap-south-1a"
  env                = "dev"
}

data "aws_ssm_parameter" "al2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

locals {
  al2_ami = data.aws_ssm_parameter.al2_ami.value
}


module "web_ec2" {
  source = "../../modules/ec2"

  project     = "myapp"
  environment = "dev"
  component   = "web"

  ami_id        = local.al2_ami  # Amazon Linux 2 (ap-south-1)
  instance_type = "t2.micro"

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id  # First public subnet

  key_name   = "myapp-dev-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Make sure this exists on your laptop

  user_data = file("${path.module}/scripts/bootstrap.sh")
  app_port  = 80
}

