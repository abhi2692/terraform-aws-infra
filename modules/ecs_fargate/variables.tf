variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "cpu" {
  type        = string
  description = "CPU units"
  default     = "256"
}

variable "memory" {
  type        = string
  description = "Memory in MiB"
  default     = "512"
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "task_definition_arn" {
  type        = string
  description = "ECS task definition ARN (updated via GitHub Actions)"
}

variable "container_name" {
  type        = string
  description = "Name of the container in task definition"
  default     = "myapp"
}

variable "container_port" {
  type        = number
  description = "Port your app listens on inside container"
  default     = 3000
}

variable "alb_security_group_id" {
  description = "The ALB security group ID to allow inbound traffic"
  type        = string
}

