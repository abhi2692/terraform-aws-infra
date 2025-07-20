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