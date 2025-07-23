variable "project" {}
variable "environment" {}
variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "target_port" {
  default = 80
}

variable "enable_alb" {
  type    = bool
  default = true
}

variable "target_type" {
  description = "The target type for the target group (ip for Fargate, instance for EC2)"
  type        = string
  default     = "ip"
}