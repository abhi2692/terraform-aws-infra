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

variable "container_image" {
  type        = string
  description = "Container image URI"
  default     = "public.ecr.aws/nginx/nginx:latest"
}

variable "container_port" {
  type        = number
  description = "Port container listens on"
  default     = 80
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
