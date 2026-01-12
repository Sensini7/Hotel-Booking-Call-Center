# Hotel-Booking-Call-Center

Infrastructure as Code (IaC) components for Amazon Connect Hotel Booking Call Center using Terraform.

## Project Overview

This project contains Terraform infrastructure code to deploy and manage Amazon Connect resources for an Employee Booking call center system. The infrastructure includes:

- **Contact Flows**: Pre-configured flows for call handling
- **Hours of Operation**: Business hours configuration
- **Queues**: Call routing queues for authenticated and unknown callers
- **Routing Profiles**: Agent routing configuration
- **Users**: Agent user accounts for the CCP panel

## Repository Structure

```
.
├── terraform/                    # Terraform infrastructure code
│   ├── modules/                  # Reusable Terraform modules
│   │   ├── hours-of-operation/  # Hours of operation module
│   │   ├── queue/               # Queue module
│   │   ├── routing-profile/     # Routing profile module
│   │   └── user/                # User module
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Variable definitions
│   ├── outputs.tf               # Output values
│   ├── backend.tf               # Backend configuration
│   └── README.md                # Detailed Terraform documentation
├── .github/
│   └── workflows/
│       └── terraform.yml        # GitHub Actions CI/CD workflow
├── EmployeeBooking_MainFlow.json           # Main contact flow
├── EmployeeBooking_TransferToQueue.json   # Transfer to queue flow
├── Default customer queue.json             # Default queue flow
└── README.md                    # This file
```

## Quick Start

1. **Prerequisites**
   - AWS Account with Amazon Connect instance in `us-east-1`
   - Terraform >= 1.0
   - AWS CLI configured
   - S3 bucket for Terraform state

2. **Configure Backend**
   ```bash
   cp terraform/backend.hcl.example terraform/backend.hcl
   # Edit backend.hcl with your S3 bucket details
   ```

3. **Configure Variables**
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

4. **Deploy**
   ```bash
   cd terraform
   terraform init -backend-config=backend.hcl
   terraform plan
   terraform apply
   ```

## Contact Flows

The project includes three pre-configured contact flows:

1. **EmployeeBooking_MainFlow**: Main entry point that plays welcome message and transfers to queue
2. **EmployeeBooking_TransferToQueue**: Checks hours of operation and transfers to appropriate queue
3. **Default customer queue**: Handles customer wait experience with messages and music

## Infrastructure Components

### Hours of Operation
- **Name**: `EmployeeBooking_DefaultHours`
- **Timezone**: Africa/Lagos
- **Schedule**: Monday-Friday, 8:00 AM - 7:00 PM

### Queues
- **EmployeeBooking_Authenticated**: Priority 1 queue for authenticated employees
- **EmployeeBooking_Unknown**: Priority 2 queue for unknown callers (default outbound queue)

### Routing Profile
- **Name**: `EmployeeBooking_Default`
- **Channels**: Voice only
- **Queue Priority**: Authenticated (1) → Unknown (2)

### User
- **Name**: Peleke Ngaih
- **Email**: pelekengaih@gmail.com
- **Security Profile**: Agent
- **After Call Work**: 5 seconds

## CI/CD with GitHub Actions

The project includes a GitHub Actions workflow for automated Terraform deployment. See `.github/workflows/terraform.yml` for details.

### Required GitHub Secrets
- `AWS_ROLE_ARN`: IAM role for GitHub Actions (OIDC)
- `TF_STATE_BUCKET`: S3 bucket for Terraform state
- `CONNECT_INSTANCE_ID`: Amazon Connect instance ID
- `INSTANCE_PHONE_NUMBER_ID`: Phone number ID/ARN
- `USER_PASSWORD`: User password

## Documentation

For detailed Terraform documentation, see [terraform/README.md](terraform/README.md).

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request
4. The GitHub Actions workflow will run `terraform plan` and comment on the PR

## License

This project is provided as-is for use with Amazon Connect.
