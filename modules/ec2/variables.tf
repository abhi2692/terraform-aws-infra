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

variable "iam_instance_profile" {
  description = "IAM instance profile to attach to the EC2 instance"
  type        = string
  default     = null

}

variable "ingress_cidr_rules" {
  description = "List of ingress rules based on CIDR blocks"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

variable "ingress_sg_rules" {
  description = "List of ingress rules based on Security Groups"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    source_security_group_id = string
    description              = string
  }))
  default = []
}

