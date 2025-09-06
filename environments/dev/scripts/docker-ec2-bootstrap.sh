#!/bin/bash
# docker-ec2-bootstrap.sh
# Use this script as EC2 User Data for installing Docker on Amazon Linux 2/2023

set -e

# Update and install dependencies
yum update -y
yum install -y docker

# Enable and start Docker service
systemctl enable docker
systemctl start docker

# Add ec2-user to docker group (so you don't need sudo for docker)
usermod -aG docker ec2-user

# Log success
echo "Docker installation and setup complete" > /var/log/docker-bootstrap.log
