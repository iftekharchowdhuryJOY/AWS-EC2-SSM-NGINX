# Secure EC2 Nginx Server with SSM

This Terraform configuration creates a secure EC2 instance running Nginx with AWS Systems Manager (SSM) access only - no SSH keys required.

## Security Features

- ✅ No SSH access (uses AWS SSM for secure shell access)
- ✅ Minimal security group (HTTP only)
- ✅ IAM role with least privilege principles
- ✅ Automatic Nginx installation via user data

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Plan the deployment:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Access the server via SSM (no SSH needed):
   ```bash
   aws ssm start-session --target <instance-id>
   ```

## Cleanup

```bash
terraform destroy
```

## Security Note

This configuration follows AWS security best practices by eliminating SSH access and using SSM for secure instance management.