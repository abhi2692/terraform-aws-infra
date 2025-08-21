#!/bin/bash
set -e

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

# Install kubectl (latest stable for EKS 1.32, adjust as needed)
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.32.0/2024-06-13/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Optionally install jq and other useful tools
sudo yum install -y jq

echo "Bootstrap complete: AWS CLI v2 and kubectl installed."