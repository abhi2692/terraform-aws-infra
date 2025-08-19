variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL"
  type        = string
}

variable "namespace" {
  description = "Namespace for the controller"
  type        = string
  default     = "kube-system"
}

variable "create_eks" {
  description = "Whether to create EKS resources"
  type        = bool
  default     = true
}

variable "eks_cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  type        = string
}

variable "eks_cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data (base64 encoded)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}