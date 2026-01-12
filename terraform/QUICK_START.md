# Quick Start Guide

## Step 1: Find Your Connect Instance ID

1. Go to Amazon Connect Console
2. Select your instance
3. Copy the Instance ID (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

## Step 2: Find Your Phone Number ID

1. In Amazon Connect Console, go to **Phone numbers** under **Telephony**
2. Click on your phone number
3. Copy the ARN or ID
   - ARN format: `arn:aws:connect:us-east-1:ACCOUNT_ID:instance/INSTANCE_ID/phone-number/PHONE_NUMBER_ID`
   - Or just the ID portion

## Step 3: Set Up S3 Backend

1. Create an S3 bucket (if not exists):
   ```bash
   aws s3 mb s3://your-terraform-state-bucket --region us-east-1
   ```

2. (Optional) Create DynamoDB table for state locking:
   ```bash
   aws dynamodb create-table \
     --table-name terraform-state-lock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST \
     --region us-east-1
   ```

3. Create `backend.hcl`:
   ```hcl
   bucket         = "your-terraform-state-bucket"
   key            = "amazon-connect/employee-booking/terraform.tfstate"
   region         = "us-east-1"
   encrypt        = true
   dynamodb_table = "terraform-state-lock"
   ```

## Step 4: Configure Variables

Create `terraform.tfvars`:

```hcl
# Required
connect_instance_id     = "your-instance-id-here"
instance_phone_number_id = "arn:aws:connect:us-east-1:ACCOUNT:instance/INSTANCE/phone-number/ID"
user_password           = "YourSecurePassword123!"

# Optional (with defaults)
aws_region              = "us-east-1"
routing_profile_description = "Default routing profile for Employee Booking service"
user_first_name         = "Peleke"
user_last_name          = "Ngaih"
user_email              = "pelekengaih@gmail.com"
user_phone_number       = "+1234567890"  # Optional
user_auto_accept        = false

# Tags
tags = {
  Environment = "production"
  Project     = "EmployeeBooking"
  ManagedBy   = "Terraform"
}
```

## Step 5: Initialize and Deploy

```bash
cd terraform

# Initialize with backend
terraform init -backend-config=backend.hcl

# Review the plan
terraform plan

# Apply (creates resources)
terraform apply
```

## Step 6: Verify Resources

After deployment, verify in Amazon Connect Console:

1. **Hours of Operation**: Should see `EmployeeBooking_DefaultHours`
2. **Queues**: Should see `EmployeeBooking_Authenticated` and `EmployeeBooking_Unknown`
3. **Routing Profiles**: Should see `EmployeeBooking_Default`
4. **Users**: Should see user `Peleke Ngaih`

## Troubleshooting

### Error: Phone number not found
- Verify the phone number ID/ARN is correct
- Ensure the phone number is associated with your Connect instance

### Error: Security profile "Agent" not found
- The "Agent" security profile should exist by default in Connect
- If not, create it manually or update the data source

### Error: State locked
```bash
terraform force-unlock <LOCK_ID>
```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This will delete all created resources!
