output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = var.enable_ec2 ? module.web_ec2[0].ec2_instance_id : null
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = var.enable_ec2 ? module.web_ec2[0].ec2_public_dns : null
}

output "ec2_elastic_ip" {
  description = "Elastic IP of the EC2 instance"
  value       = var.enable_ec2 ? module.web_ec2[0].ec2_elastic_ip : null
}

output "docker_ec2_instance_ip" {
  description = "Ip of the Docker EC2 instance"
  value       = var.enable_docker_ec2 ? module.docker_ec2[0].ec2_elastic_id : null
}
# bastion ec2 outputs

output "bastion_public_ip" {
  value       = module.bastion_ec2[0].ec2_elastic_ip
  description = "Public IP of the bastion EC2 instance"
}

# EKS Outputs

output "eks_cluster_name" {
  value = module.eks.eks_cluster_name
}

output "eks_cluster_role_arn" {
  value = module.eks.eks_cluster_iam_role_arn
}

output "eks_node_role_arn" {
  value = module.eks.eks_node_iam_role_arn
}

output "cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = "Security Group ID for the EKS cluster"
}

