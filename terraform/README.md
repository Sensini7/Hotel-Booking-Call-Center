# Amazon Connect Employee Booking - Terraform Infrastructure

This Terraform configuration creates the necessary infrastructure components for the Amazon Connect Employee Booking call center system.

## Overview

This infrastructure as code (IaC) creates:
- **Hours of Operation**: `EmployeeBooking_DefaultHours` (Monday-Friday, 8AM-7PM, Africa/Lagos timezone)
- **Queues**: 
  - `EmployeeBooking_Authenticated` (Priority 1)
  - `EmployeeBooking_Unknown` (Priority 2)
- **Routing Profile**: `EmployeeBooking_Default`
- **User**: Agent user for the CCP panel

## Prerequisites

1. AWS Account with Amazon Connect instance in `us-east-1`
2. Terraform >= 1.0 installed
3. AWS CLI configured with appropriate credentials
4. S3 bucket for Terraform state storage
5. (Optional) DynamoDB table for state locking

## Architecture

The infrastructure is organized into reusable modules:

```
terraform/
├── modules/
│   ├── hours-of-operation/  # Hours of operation module
│   ├── queue/               # Queue module
│   ├── routing-profile/     # Routing profile module
│   └── user/                # User module
├── main.tf                  # Main configuration
├── variables.tf             # Variable definitions
├── outputs.tf               # Output values
├── backend.tf               # Backend configuration
└── versions.tf              # Provider requirements
```

## Setup Instructions

### 1. Configure Backend

Create a `backend.hcl` file (based on `backend.hcl.example`):

```hcl
bucket         = "your-terraform-state-bucket"
key            = "amazon-connect/employee-booking/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-state-lock"  # Optional
```

### 2. Configure Variables

Copy `terraform.tfvars.example` to `terraform.tfvars` and update with your values:

```hcl
aws_region          = "us-east-1"
connect_instance_id = "your-connect-instance-id"
instance_phone_number_id = "arn:aws:connect:us-east-1:ACCOUNT_ID:instance/INSTANCE_ID/phone-number/PHONE_NUMBER_ID"
user_password       = "YourSecurePassword123!"
```

**Important**: Never commit `terraform.tfvars` to version control as it contains sensitive data.

### 3. Initialize Terraform

```bash
cd terraform
terraform init -backend-config=../backend.hcl
```

### 4. Review Plan

```bash
terraform plan
```

### 5. Apply Configuration

```bash
terraform apply
```

## Module Details

### Hours of Operation Module

Creates hours of operation with:
- **Name**: `EmployeeBooking_DefaultHours`
- **Timezone**: `Africa/Lagos`
- **Schedule**: Monday-Friday, 8:00 AM - 7:00 PM

### Queue Module

Creates queues with:
- Hours of operation association
- Outbound caller ID configuration
- Configurable max contacts and status

### Routing Profile Module

Creates routing profile with:
- Queue priorities and delays
- Channel concurrency settings
- Default outbound queue

### User Module

Creates user with:
- Identity information (name, email)
- Phone configuration
- Security profile assignment
- Routing profile assignment
- After contact work timeout

## Variables

### Required Variables

- `connect_instance_id`: Amazon Connect instance ID
- `instance_phone_number_id`: Phone number ID/ARN for outbound calls
- `user_password`: Password for the user account

### Optional Variables

- `aws_region`: AWS region (default: `us-east-1`)
- `routing_profile_description`: Description for routing profile
- `user_first_name`: User first name (default: `Peleke`)
- `user_last_name`: User last name (default: `Ngaih`)
- `user_email`: User email (default: `pelekengaih@gmail.com`)
- `user_phone_number`: User phone number (optional)
- `user_auto_accept`: Auto-accept calls (default: `false`)
- `tags`: Tags to apply to all resources

## Outputs

- `hours_of_operation_id`: Hours of operation identifier
- `queue_authenticated_id`: Authenticated queue identifier
- `queue_unknown_id`: Unknown queue identifier
- `routing_profile_id`: Routing profile identifier
- `user_id`: User identifier
- `user_arn`: User ARN

## GitHub Actions Deployment

This repository includes a GitHub Actions workflow for automated Terraform deployment.

### Required Secrets

Configure the following secrets in your GitHub repository:

- `AWS_ROLE_ARN`: IAM role ARN for GitHub Actions (OIDC)
- `TF_STATE_BUCKET`: S3 bucket for Terraform state
- `CONNECT_INSTANCE_ID`: Amazon Connect instance ID
- `INSTANCE_PHONE_NUMBER_ID`: Phone number ID/ARN
- `USER_PASSWORD`: User password

### Workflow Behavior

- **Pull Requests**: Runs `terraform plan` and comments on the PR
- **Push to main**: Runs `terraform plan` and `terraform apply`
- **Manual Trigger**: Available via `workflow_dispatch`

## Finding Your Phone Number ID

To find your phone number ID in Amazon Connect:

1. Navigate to Amazon Connect console
2. Go to **Phone numbers** under **Telephony**
3. Click on your phone number
4. Copy the ARN or ID from the details page

The ARN format is:
```
arn:aws:connect:us-east-1:ACCOUNT_ID:instance/INSTANCE_ID/phone-number/PHONE_NUMBER_ID
```

## Security Considerations

1. **State File**: Stored in encrypted S3 bucket
2. **Sensitive Variables**: Use `terraform.tfvars` (not committed) or environment variables
3. **IAM Permissions**: Ensure minimal required permissions for Terraform execution
4. **User Passwords**: Store in secrets management (AWS Secrets Manager, GitHub Secrets)

## Troubleshooting

### Common Issues

1. **Phone Number ID Not Found**: Verify the phone number exists in your Connect instance
2. **Security Profile Not Found**: Ensure "Agent" security profile exists
3. **State Lock**: If state is locked, check DynamoDB table or manually unlock

### Unlocking State

```bash
terraform force-unlock <LOCK_ID>
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all created resources. Ensure you have backups if needed.

## Support

For issues or questions, please refer to:
- [Amazon Connect Documentation](https://docs.aws.amazon.com/connect/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
