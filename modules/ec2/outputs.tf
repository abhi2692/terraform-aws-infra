output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app.id
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.app.public_dns
}

output "ec2_elastic_ip" {
  description = "Elastic IP assigned to the EC2 instance"
  value       = aws_eip.ec2_eip.public_ip
}