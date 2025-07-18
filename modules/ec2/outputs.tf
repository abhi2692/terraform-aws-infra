output "ec2_instance_id" {
  value = aws_instance.app.id
}

output "ec2_public_dns" {
  value = aws_instance.app.public_dns
}

output "ec2_elastic_ip" {
  value = aws_eip.ec2_eip.public_ip
}
