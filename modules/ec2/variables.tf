variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "associate_public_ip_address" {
  type    = bool
  default = true
}

variable "key_name" {
  type = string
}

variable "user_data" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "component" {
  type = string
}

# modules/ec2/outputs.tf

output "instance_id" {
  value = aws_instance.app.id
}

output "public_ip" {
  value = aws_instance.app.public_ip
}

variable "vpc_id" {
  type = string
}

variable "public_key" {
  type = string
}

variable "app_port" {
  type = number
}