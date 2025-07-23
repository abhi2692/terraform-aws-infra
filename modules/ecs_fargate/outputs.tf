output "ecs_cluster_id" {
  value = aws_ecs_cluster.app_cluster.id
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "security_group_id" {
  description = "ID of the ECS Fargate security group"
  value       = aws_security_group.ecs_sg.id
}