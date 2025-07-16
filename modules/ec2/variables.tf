variable "project" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "component" {
  description = "Component name (e.g., ec2, web, app)"
  type        = string
}

# Keep the rest same:
variable "ami_id"        {}
variable "instance_type" {}
variable "vpc_id"        {}
variable "subnet_id"     {}
variable "key_name"      {}
variable "public_key"    {}
variable "user_data"     {}
variable "app_port"      {}
