# terraform-aws-infra

## Overview

This repository provisions AWS infrastructure using Terraform, including VPC, EC2, ECS Fargate, ALB, and EKS modules. Infrastructure changes are automated via GitHub Actions.

## Directory Structure

- `environments/dev/` – Environment-specific Terraform configuration and variables
- `modules/` – Reusable Terraform modules (vpc, ec2, ecs_fargate, alb, eks)
- `.github/workflows/terraform.yaml` – Main CI/CD pipeline for Terraform
- `.github/workflows/terraform-destroy.yaml` – Manual workflow to destroy all resources

## Getting Started

### Prerequisites
- AWS account and IAM user with permissions for S3, DynamoDB, EC2, EKS, ECS, VPC, IAM, etc.
- SSH public key (do not commit private keys)

### Setup
1. **Fork/clone this repo.**
2. **Add GitHub Secrets:**
   - `AWS_ACCESS_KEY_ID` – IAM user access key
   - `AWS_SECRET_ACCESS_KEY` – IAM user secret key
   - `PUBLIC_KEY` – Your SSH public key (contents of `id_rsa.pub`)
3. **(Optional) Edit variables in `environments/dev/variables.tf` as needed.**

### Key Variables
You can override these via GitHub Actions secrets or by editing `variables.tf`:

- `public_key` – SSH public key (set via secret)
- `kubernetes_version` – EKS cluster version (default: 1.32)
- `create_eks` – Whether to create EKS resources (default: true)
- `enable_ec2`, `enable_ecs_fargate`, `enable_alb` – Enable/disable respective modules

## CI/CD with GitHub Actions

### Main Pipeline
Runs on push/PR to `main` (except for changes to README or workflow files):
- `terraform init`
- `terraform fmt -check`
- `terraform validate`
- `terraform plan`
- `terraform apply` (on push to main)

### Destroy Workflow
To destroy all resources, use the manual workflow:
1. Go to the **Actions** tab in GitHub.
2. Select **Terraform Destroy**.
3. Click **Run workflow**.

## EKS Version Management

To upgrade EKS, update the `kubernetes_version` variable in `environments/dev/variables.tf` and re-apply. If you want to destroy and re-create the cluster (e.g., for major version jumps), use the destroy workflow first.

## Security Notes
- **Never commit private keys.**
- Public keys are safe to use as secrets or in the repo.

## License

MIT