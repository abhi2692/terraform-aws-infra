output "eks_cluster_name" {
  value       = var.create_eks ? aws_eks_cluster.mycluster[0].name : null
  description = "Name of the EKS cluster"
}

output "eks_cluster_endpoint" {
  value       = var.create_eks ? aws_eks_cluster.mycluster[0].endpoint : null
  description = "EKS cluster endpoint"
}

output "eks_cluster_iam_role_arn" {
  value       = var.create_eks ? aws_iam_role.eks_cluster[0].arn : null
  description = "IAM role ARN for EKS cluster"
}

output "eks_node_iam_role_arn" {
  value       = var.create_eks ? aws_iam_role.eks_node[0].arn : null
  description = "IAM role ARN for EKS node group"
}
