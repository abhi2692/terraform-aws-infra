output "alb_controller_role_arn" {
  value       = var.create_eks ? aws_iam_role.alb_controller[0].arn : null
  description = "ARN of the IAM role for AWS Load Balancer Controller"
}