output "eks_cluster_name" {
  value       = var.create_eks ? aws_eks_cluster.mycluster[0].name : null
  description = "Name of the EKS cluster"
}

output "eks_cluster_endpoint" {
  value       = var.create_eks ? aws_eks_cluster.mycluster[0].endpoint : null
  description = "EKS cluster endpoint"
}

output "eks_cluster_certificate_authority_data" {
  value       = var.create_eks ? aws_eks_cluster.mycluster[0].certificate_authority[0].data : null
  description = "EKS cluster CA data"
}

output "eks_cluster_iam_role_arn" {
  value       = var.create_eks ? aws_iam_role.eks_cluster[0].arn : null
  description = "IAM role ARN for EKS cluster"
}

output "eks_node_iam_role_arn" {
  value       = var.create_eks ? aws_iam_role.eks_node[0].arn : null
  description = "IAM role ARN for EKS node group"
}

output "cluster_security_group_id" {
  value       = var.create_eks ? aws_eks_cluster.mycluster[0].vpc_config[0].cluster_security_group_id : null
  description = "Security Group ID for the EKS cluster"
}

output "oidc_provider_arn" {
  value       = var.create_eks ? aws_iam_openid_connect_provider.eks_oidc[0].arn : null
  description = "ARN of the OIDC provider for IRSA"
}

output "oidc_provider_url" {
  value       = var.create_eks ? aws_eks_cluster.mycluster[0].identity[0].oidc[0].issuer : null
  description = "OIDC issuer URL for the EKS cluster"
}