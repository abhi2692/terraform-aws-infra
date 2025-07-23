output "alb_dns_name" {
  value = aws_alb.myalb.dns_name
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "target_group_arn" {
  value = aws_alb_target_group.mytg.arn
}

output "security_group_id" {
  description = "The security group ID of the ALB"
  value       = aws_security_group.alb_sg.id
}
