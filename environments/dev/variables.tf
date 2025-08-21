variable "public_key" {
  description = "SSH public key"
  type        = string
}

variable "ami_id" {
  type    = string
  default = "ami-0c1a7f89451184c8b"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "env" {
  type    = string
  default = "dev"
}

variable "enable_ec2" {
  type    = bool
  default = true
}

# ECS Fargate specific variables

variable "enable_ecs_fargate" {
  type    = bool
  default = true
}

# ALB specific variables

variable "enable_alb" {
  type    = bool
  default = false
}

# EKS specific variables

variable "create_eks" {
  description = "Whether to create EKS resources"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
  default     = "dev-cluster"
}

variable "kubernetes_version" {
  description = "K8s version"
  type        = string
  default     = "1.32"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"

}
