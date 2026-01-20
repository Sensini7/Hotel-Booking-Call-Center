# Hotel Booking Call Center - Receiving First Call

> **Branch**: `receiving-First-Call`
> **Purpose**: Foundation infrastructure for Amazon Connect call center with basic agent setup and contact flows

This branch contains the foundational Infrastructure as Code (IaC) for setting up an Amazon Connect hotel booking call center. It establishes the core infrastructure needed to receive and route the first inbound call with pre-configured contact flows.

## What This Branch Does

This is the **first phase** of the project that sets up:

1. ✅ **Contact Flows** - Pre-built call flows for welcome message and routing
2. ✅ **Hours of Operation** - Business hours configuration (Monday-Friday, 8:00 AM - 7:00 PM WAT)
3. ✅ **Call Queues** - Two queues for routing authenticated and unknown callers
4. ✅ **Routing Profile** - Agent routing configuration with queue priorities
5. ✅ **Agent User** - First agent user account for handling calls via CCP

**What's NOT in this branch:**
- Lambda functions for database lookups
- DynamoDB tables
- Lex bot integration
- SES email notifications
- Custom CCP hosting (S3/CloudFront)

## Repository Structure

```
.
├── Contact Flows/                        # Pre-configured contact flows (JSON)
│   ├── EmployeeBooking_MainFlow.json            # Entry point flow
│   ├── EmployeeBooking_TransferToQueue.json     # Queue transfer logic
│   └── Default customer queue.json              # Customer wait experience
├── terraform/
│   ├── modules/
│   │   ├── hours-of-operation/           # Business hours module
│   │   ├── queue/                        # Call queue module
│   │   ├── routing-profile/              # Agent routing module
│   │   └── user/                         # Agent user module
│   ├── main.tf                           # Main infrastructure configuration
│   ├── variables.tf                      # Input variable definitions
│   ├── outputs.tf                        # Output values
│   ├── backend.tf                        # S3 backend configuration
│   └── provider.tf                       # AWS provider configuration
├── .github/
│   └── workflows/
│       └── receiving-first-call.yml      # CI/CD deployment workflow
└── README.md                             # This file
```

## Contact Flows

The [Contact Flows/](Contact%20Flows/) directory contains three pre-configured contact flows that work together to handle incoming calls:

### 1. EmployeeBooking_MainFlow
**Purpose**: Main entry point for all incoming calls

**Flow Logic:**
1. Enable flow logging
2. Set voice to Joanna (Amazon Polly)
3. Play "WelcomeChime" audio prompt
4. Play message: "Welcome to the Acme Travel Employee Booking service."
5. Set target queue to `EmployeeBooking_Unknown`
6. Transfer to `EmployeeBooking_TransferToQueue` flow
7. Error handling: Play "experiencing technical difficulties" message and disconnect

### 2. EmployeeBooking_TransferToQueue
**Purpose**: Check business hours and route to appropriate queue

**Flow Logic:**
1. Check hours of operation (`EmployeeBooking_DefaultHours`)
2. **If in hours**: Transfer to queue
3. **If out of hours**: Play message and disconnect
4. Error handling with fallback disconnect

### 3. Default customer queue
**Purpose**: Customer wait experience while in queue

**Flow Logic:**
1. Play hold music or messages while waiting
2. Periodic announcements
3. Handle customer disconnect
4. Connect to available agent

## Infrastructure Components

### 1. Hours of Operation
**Resource**: `EmployeeBooking_DefaultHours`

- **Timezone**: `Africa/Lagos` (West Africa Time - WAT)
- **Schedule**:
  - Monday - Friday: 8:00 AM - 7:00 PM
  - Weekends: Closed
- **Purpose**: Controls when agents can receive calls and when to route to after-hours flow

### 2. Call Queues

#### Authenticated Queue
- **Name**: `EmployeeBooking_Authenticated`
- **Priority**: 1 (highest)
- **Purpose**: For verified employee callers
- **Hours**: Uses `EmployeeBooking_DefaultHours`

#### Unknown Queue
- **Name**: `EmployeeBooking_Unknown`
- **Priority**: 2
- **Purpose**: Default queue for unverified callers and outbound calls
- **Hours**: Uses `EmployeeBooking_DefaultHours`

### 3. Routing Profile
**Name**: `EmployeeBooking_Default`

- **Channels**: Voice only
- **Queue Routing**:
  1. `EmployeeBooking_Authenticated` (Priority 1, Delay 0s)
  2. `EmployeeBooking_Unknown` (Priority 2, Delay 0s)
- **Default Outbound Queue**: `EmployeeBooking_Unknown`

### 4. Agent User
**Configuration**:
- **Full Name**: Peleke Ngaih
- **Username**: pelekengaih
- **Email**: pelekengaih@gmail.com
- **Security Profile**: Agent (read-only access)
- **Routing Profile**: `EmployeeBooking_Default`
- **Phone Type**: Soft phone (browser-based)
- **After Call Work (ACW)**: 5 seconds
- **Auto Accept**: Enabled (calls auto-connect)

## Quick Start

### Prerequisites

- AWS Account with Amazon Connect instance already created
- Amazon Connect instance in `us-east-1` region
- Terraform >= 1.6.0 installed
- AWS CLI configured with appropriate credentials
- S3 bucket for Terraform state storage
- GitHub repository secrets configured (for CI/CD)

### Local Deployment

#### 1. Clone the Repository
```bash
git clone <repository-url>
cd Hotel-Booking-Call-Center
git checkout receiving-First-Call
```

#### 2. Configure Terraform Backend

Create `terraform/backend.hcl`:
```hcl
bucket         = "your-terraform-state-bucket"
key            = "amazon-connect/employee-booking/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-state-lock"  # Optional: for state locking
```

#### 3. Set Required Variables

Create `terraform/terraform.tfvars`:
```hcl
# Amazon Connect Instance
connect_instance_id       = "12345678-1234-1234-1234-123456789012"
instance_phone_number_id  = "arn:aws:connect:us-east-1:123456789012:instance/12345678-1234-1234-1234-123456789012/phone-number/abcd1234-5678-90ab-cdef-1234567890ab"

# Agent User Configuration
user_username     = "pelekengaih"
user_first_name   = "Peleke"
user_last_name    = "Ngaih"
user_email        = "pelekengaih@gmail.com"
user_phone_number = "+1234567890"
user_password     = "SecurePassword123!"  # Change this!

# Optional: Override defaults
tags = {
  Environment = "dev"
  Project     = "HotelBooking"
  ManagedBy   = "Terraform"
}
```

#### 4. Initialize and Deploy
```bash
cd terraform

# Initialize Terraform
terraform init -backend-config=backend.hcl

# Review the plan
terraform plan

# Apply the infrastructure
terraform apply
```

#### 5. Import Contact Flows

**Important**: Contact flows must be imported manually via Amazon Connect Console:

1. Log in to Amazon Connect Console
2. Navigate to **Routing** > **Contact flows**
3. Click **Create contact flow** (3 times, one for each flow)
4. For each flow:
   - Click **Save** dropdown > **Import flow (beta)**
   - Upload the corresponding JSON file from `Contact Flows/` directory
   - Click **Save** and **Publish**
5. Assign `EmployeeBooking_MainFlow` to your phone number:
   - Go to **Channels** > **Phone numbers**
   - Edit your phone number
   - Select `EmployeeBooking_MainFlow` as the contact flow
   - Save

#### 6. Verify Deployment
```bash
# Get important resource IDs
terraform output

# Example outputs:
# - hours_of_operation_id
# - authenticated_queue_arn
# - routing_profile_id
# - user_id
```

### CI/CD Deployment (GitHub Actions)

#### Required GitHub Secrets

Configure these in **Settings** > **Secrets and variables** > **Actions**:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ROLE_ARN` | IAM role ARN for OIDC authentication | `arn:aws:iam::123456789012:role/GitHubActionsTerraformRole` |
| `TF_STATE_BUCKET` | S3 bucket for Terraform state | `my-terraform-state-bucket` |
| `CONNECT_INSTANCE_ID` | Amazon Connect instance ID | `12345678-1234-1234-1234-123456789012` |
| `INSTANCE_PHONE_NUMBER_ID` | Phone number ARN | `arn:aws:connect:us-east-1:...` |
| `USER_PASSWORD` | Agent user password | `SecurePassword123!` |

#### Workflow Trigger

The workflow runs on:
- Manual trigger via **Actions** > **receiving first call workflow** > **Run workflow**
- Requires approval in `production` environment before applying

#### Workflow Steps

1. **Terraform Plan** - Validates and creates execution plan
2. **Wait for Approval** - Production environment approval required
3. **Terraform Apply** - Deploys infrastructure to AWS

**Note**: Contact flows must still be imported manually after deployment.

## How to Use After Deployment

### 1. Import Contact Flows (Manual Step)

See step 5 in Local Deployment above for detailed instructions.

### 2. Access the Contact Control Panel (CCP)

1. Navigate to your Amazon Connect instance:
   ```
   https://YOUR-INSTANCE-NAME.my.connect.aws/ccp-v2
   ```

2. Log in with agent credentials:
   - **Username**: pelekengaih
   - **Password**: (the password you set in terraform.tfvars)

3. Set your status to **Available**

### 3. Make a Test Call

1. Call your Amazon Connect phone number
2. You'll hear:
   - WelcomeChime audio
   - "Welcome to the Acme Travel Employee Booking service."
3. The call transfers to queue (`EmployeeBooking_Unknown`)
4. The agent sees the incoming call in the CCP
5. Accept the call to connect

### 4. Verify Hours of Operation

Test after-hours behavior:
1. Call outside of 8:00 AM - 7:00 PM WAT (Monday-Friday)
2. You should hear an out-of-hours message
3. Call disconnects (no agent routing)

## Contact Flow Details

### Flow Sequence Diagram

```
Incoming Call
     │
     ▼
[EmployeeBooking_MainFlow]
     │
     ├─► Enable Logging
     ├─► Set Voice (Joanna)
     ├─► Play WelcomeChime
     ├─► Play Welcome Message
     ├─► Set Target Queue (Unknown)
     │
     ▼
[EmployeeBooking_TransferToQueue]
     │
     ├─► Check Hours of Operation
     │   │
     │   ├─► In Hours ──► Transfer to Queue
     │   │                      │
     │   │                      ▼
     │   │              [Default customer queue]
     │   │                      │
     │   │                      ├─► Play Hold Music
     │   │                      ├─► Wait for Agent
     │   │                      │
     │   │                      ▼
     │   │                Connect to Agent
     │   │
     │   └─► Out of Hours ──► Play Message ──► Disconnect
     │
     └─► Error ──► Technical Difficulties ──► Disconnect
```

### Customizing Contact Flows

To modify contact flows:

1. Export current flow from Amazon Connect Console
2. Edit the JSON file
3. Update ARNs and IDs to match your environment
4. Import modified flow back to Amazon Connect

**Important**: Contact flow JSON files contain environment-specific ARNs. These must be updated when deploying to a new instance.

## Customization

### Change Business Hours

Edit `terraform/main.tf`, modify the hours_of_operation module:

```hcl
module "hours_of_operation" {
  source = "./modules/hours-of-operation"

  instance_id   = var.connect_instance_id
  name          = "EmployeeBooking_DefaultHours"
  time_zone     = "America/New_York"  # Change timezone

  # Modify schedule
  config = [
    {
      day        = "MONDAY"
      start_time = { hours = 9, minutes = 0 }
      end_time   = { hours = 17, minutes = 0 }
    },
    # Add more days...
  ]
}
```

### Add More Agents

Duplicate the user module in `terraform/main.tf`:

```hcl
module "user_agent2" {
  source = "./modules/user"

  instance_id     = var.connect_instance_id
  username        = "jane.doe"
  first_name      = "Jane"
  last_name       = "Doe"
  email           = "jane.doe@example.com"
  phone_number    = "+1234567890"
  password        = var.user_password
  routing_profile_id = module.routing_profile.routing_profile_id
  # ... other settings
}
```

### Change Queue Priority

Edit the routing profile module in `terraform/main.tf`:

```hcl
queue_configs = [
  {
    queue_id = module.queue_authenticated.queue_id
    channel  = "VOICE"
    delay    = 10  # Add 10 second delay before routing
    priority = 1
  },
  # ...
]
```

## Outputs

After successful deployment, Terraform outputs these values:

| Output | Description |
|--------|-------------|
| `hours_of_operation_id` | Hours of operation resource ID |
| `hours_of_operation_arn` | Hours of operation ARN |
| `authenticated_queue_id` | Authenticated queue ID |
| `authenticated_queue_arn` | Authenticated queue ARN |
| `unknown_queue_id` | Unknown queue ID |
| `unknown_queue_arn` | Unknown queue ARN |
| `routing_profile_id` | Routing profile ID |
| `routing_profile_arn` | Routing profile ARN |
| `user_id` | Agent user ID |
| `user_arn` | Agent user ARN |

## Troubleshooting

### Issue: "Instance not found"
**Error**: `ResourceNotFoundException: Instance 12345... not found`

**Solution**: Verify your `connect_instance_id` is correct:
```bash
aws connect list-instances --region us-east-1
```

### Issue: "Phone number not found"
**Error**: `ResourceNotFoundException: Phone number not found`

**Solution**: Get the correct phone number ARN:
```bash
aws connect list-phone-numbers-v2 \
  --target-arn arn:aws:connect:us-east-1:ACCOUNT:instance/INSTANCE-ID \
  --region us-east-1
```

### Issue: Contact flow import fails
**Error**: "Invalid JSON" or flow doesn't work after import

**Solution**: Update environment-specific ARNs in the JSON files:
1. Replace instance IDs with your instance ID
2. Replace queue ARNs with your queue ARNs
3. Replace prompt ARNs with your prompt ARNs (or remove prompt blocks)

### Issue: "User already exists"
**Error**: `DuplicateResourceException: User with username 'pelekengaih' already exists`

**Solution**: Either:
1. Delete the existing user in Amazon Connect Console
2. Change the username in `terraform.tfvars`
3. Import existing user into Terraform state

### Issue: Terraform state locked
**Error**: `Error acquiring state lock`

**Solution**:
```bash
# Force unlock (use carefully!)
terraform force-unlock LOCK_ID
```

### Issue: Contact flow not assigned to phone number
**Symptom**: Calls disconnect immediately with no prompts

**Solution**: Assign flow to phone number in Amazon Connect Console:
1. Go to **Channels** > **Phone numbers**
2. Edit your phone number
3. Select `EmployeeBooking_MainFlow` as the contact flow
4. Save

## Next Steps

After this branch is deployed, the next phases add:

1. **Lambda Functions** - Employee lookup and authentication via DynamoDB
2. **DynamoDB Tables** - Employee data and hotel booking storage
3. **Lex Bot Integration** - Conversational booking interface
4. **SES Email** - Booking confirmation emails
5. **Serverless CCP** - Custom CCP hosted on S3/CloudFront

See other branches for these features.

## Clean Up

To destroy all resources created by this branch:

### Via GitHub Actions
1. Go to **Actions** > **receiving first call workflow**
2. Run workflow
3. Approve the **destroy** job (not the apply job)

### Via Local Terraform
```bash
cd terraform
terraform destroy
```

**Warning**: This will permanently delete:
- Hours of operation
- Queues
- Routing profile
- Agent user account

**Note**: Contact flows imported via console must be manually deleted.

## Contributing

1. Create a feature branch from `receiving-First-Call`
2. Make your changes
3. Test locally with `terraform plan`
4. Submit a pull request
5. GitHub Actions will validate your changes

## Support

For issues with:
- **Terraform**: Check the [Terraform AWS Provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- **Amazon Connect**: Consult [AWS Connect documentation](https://docs.aws.amazon.com/connect/)
- **Contact Flows**: See [Amazon Connect Flow Language](https://docs.aws.amazon.com/connect/latest/adminguide/flow-language.html)
- **This Project**: Open an issue in the repository

## License

This project is provided as-is for use with Amazon Connect.
