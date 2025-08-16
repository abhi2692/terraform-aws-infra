variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

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

variable "vpc_id" {
  type = string
}

variable "public_key" {
  type = string
}

variable "app_port" {
  type = number
}