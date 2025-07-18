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
  value = module.web_ec2.ec2_instance_id
}

output "ec2_public_dns" {
  value = module.web_ec2.ec2_public_dns
}

output "ec2_elastic_ip" {
  value = module.web_ec2.ec2_elastic_ip
}
