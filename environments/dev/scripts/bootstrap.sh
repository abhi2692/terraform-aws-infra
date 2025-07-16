#!/bin/bash
set -e

# Update packages
sudo yum update -y

sudo amazon-linux-extras install nginx1.12 -y

# Start and enable nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Custom homepage
echo "<h1>Hello from EC2 - Amazon Linux 2023</h1>" | sudo tee /usr/share/nginx/html/index.html
