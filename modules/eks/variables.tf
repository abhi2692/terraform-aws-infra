variable "kubernetes_version" {
  description = "Kubernetes version for EKS control plane and node groups"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "create_eks" {
  description = "Whether to create EKS cluster and node group"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "Subnets to launch EKS in"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}
