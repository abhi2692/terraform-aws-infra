# terraform-aws-infra

## Overview

This repository provisions AWS infrastructure using Terraform, including VPC, EC2, ECS Fargate, ALB, and EKS modules. Infrastructure changes are automated via GitHub Actions.


## Directory Structure

- `environments/dev/` – Environment-specific Terraform configuration and variables
- `modules/` – Reusable Terraform modules (vpc, ec2, ecs_fargate, alb, eks)
- `.github/workflows/terraform.yaml` – Main CI/CD pipeline for Terraform
- `.github/workflows/terraform-destroy.yaml` – Manual workflow to destroy all resources

## Bastion Host (Admin EC2)

This repo provisions a dedicated EC2 instance (bastion host) in a public subnet for secure access to private AWS resources (like EKS, RDS, or private EC2 instances). The bastion host:
- Is created via the `bastion_ec2` module block in `environments/dev/main.tf`.
- Has a minimal configuration (no user data, only SSH port open).
- Is referenced in security group rules to allow access to private resources (e.g., EKS API).

**Why use a bastion host?**
- Provides a single, auditable entry point for admin access to your private AWS infrastructure.
- Avoids exposing private resources directly to the internet.
- Can be referenced in security group rules for any resource you want to access securely.

**How to use:**
1. SSH into the bastion using your private key and the output public IP:
   ```bash
   ssh -i ~/.ssh/id_rsa ec2-user@<bastion_public_ip>
   ```
2. From the bastion, you can access EKS, RDS, or other private resources as needed.
3. The bastion's security group is referenced in security group rules for EKS and can be used for other resources.

**Best practice:**
- Reference the bastion's security group in any resource's security group rule to allow admin access from the bastion only.
- Use conditional creation (`count`) for the bastion and related rules if you want to make it optional.

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
- `enable_ec2`, `enable_ecs_fargate`, `enable_alb`, `enable_bastion` – Enable/disable respective modules

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
- Bastion host should have SSH restricted to your IP for production.
- Remove manual security group changes and manage all rules via Terraform for consistency.

## License

MIT