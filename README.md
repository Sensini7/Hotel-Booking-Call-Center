# Hotel Booking Call Center - Send Email Confirmation

> **Branch**: `Send-Email-Confirmation`
> **Purpose**: Add SES email notifications for hotel booking confirmations

Adds email confirmation system using AWS SES. Builds on `Amazon-Lex-Enhanced` branch.

## What's New in This Branch

**Added:**
- ✅ **SES Lambda IAM Role** - Permissions for SES email sending and CloudWatch Logs
- ✅ **SES Lambda Function** (EmployeeBooking_SES) - Sends booking confirmation emails

**Inherited from previous branches:**
- 8 Contact Flows, Lex Bot (EmployeeBooking)
- Employee Lambda & DynamoDB, Lex Lambda & DynamoDB
- Hours of Operation, Queues, Routing Profile, Agent User

**Not Yet Included:**
- Custom CCP (main branch has this)

## Repository Structure

```
.
├── Contact Flows/                      # Same 8 flows
├── Lex Bots/
├── terraform/
│   └── modules/
│       ├── ses-lambda-role/            # NEW: SES IAM role
│       ├── ses-lambda-function/        # NEW: Email sender
│       │   ├── lambda_function.py
│       │   └── lambda_function.zip
│       ├── lex-lambda-function/
│       ├── lex-dynamodb-table/
│       ├── lambda-role/
│       ├── dynamodb-table/
│       ├── lambda-function/
│       └── ...
└── .github/workflows/
```

## New Infrastructure Components

### 1. SES Lambda IAM Role
**Name**: Lambda_EmployeeBooking_SES

**Permissions:**
- SES: SendEmail, SendRawEmail
- CloudWatch Logs: CreateLogGroup, CreateLogStream, PutLogEvents

**Note**: Separate from main Lambda role for security best practices.

### 2. SES Lambda Function
**Name**: EmployeeBooking_SES
**Runtime**: Python 3.12
**Memory**: 256 MB
**Timeout**: 7 seconds

**Purpose**: Sends HTML booking confirmation emails via Amazon SES

**Input Parameters:**
- `EmailAddress` - Recipient email address
- `BookingPrice` - Total booking cost (dollars)

**Environment Variables:**
- `SENDER_EMAIL` - Verified SES sender address (default: noreply@example.com)

**Return Values:**
- `lambdaResult`: "Success" or "Error"

## Email Template

**Subject**: "Your Hotel Booking"

**Body** (HTML):
```html
Hi

Thank you for using our service to book a hotel.
Your account will be charged for <b>[booking_price] dollars</b>.

Thank you,
The Employee Booking Line
```

## Prerequisites

### Verify SES Email Address

**Important**: SES requires email verification in sandbox mode.

1. Go to **SES Console** > **Verified identities**
2. Click **Create identity**
3. Select **Email address**
4. Enter sender email (e.g., noreply@yourcompany.com)
5. Click **Create identity**
6. Check inbox and click verification link
7. Wait for status to show **Verified**

**Sandbox Mode Limits:**
- Can only send to verified email addresses
- Maximum 200 emails per 24 hours
- Maximum 1 email per second

**To send to any email** (production):
- Request production access via SES Console
- Approval typically takes 24 hours

## Deployment

### 1. Deploy Infrastructure

```bash
git checkout Send-Email-Confirmation
cd terraform
terraform init -backend-config=backend.hcl
terraform apply
```

**New Resources Created:**
- SES Lambda IAM role and policy
- SES Lambda function

### 2. Configure Sender Email

**Update Terraform variable** in `terraform.tfvars`:

```hcl
ses_sender_email = "noreply@yourcompany.com"
```

Then redeploy:
```bash
terraform apply
```

**Or update via Lambda Console:**
1. Go to Lambda > EmployeeBooking_SES
2. **Configuration** > **Environment variables**
3. Edit `SENDER_EMAIL` to your verified address

### 3. Integrate with Contact Flow

**Add email sending to contact flow:**

1. Open contact flow in Amazon Connect Console
2. After successful Lex booking, add **Invoke AWS Lambda function** block
3. Select function: **EmployeeBooking_SES**
4. Set function parameters:
   - `EmailAddress`: `$.Attributes.EmailAddress` (from employee lookup)
   - `BookingPrice`: `$.Attributes.currentReservationPrice` (from Lex)
5. Add branches:
   - Success → Play confirmation
   - Error → Play error message (still complete booking)

**Flow Logic:**
```
Lex BookHotel (Fulfilled)
  │
  ├─► Set EmailAddress attribute (from employee record)
  ├─► Set BookingPrice attribute (from Lex session)
  ├─► Invoke EmployeeBooking_SES Lambda
  │   │
  │   ├─► lambdaResult = Success
  │   │   └─► "Email sent, thank you"
  │   │
  │   └─► lambdaResult = Error
  │       └─► "Booking confirmed, email failed"
  │
  └─► End call
```

### 4. Test Email Sending

**Via Lambda Console:**
1. Go to Lambda > EmployeeBooking_SES
2. **Test** tab > **Create test event**
3. Event JSON:
```json
{
  "Details": {
    "Parameters": {
      "EmailAddress": "your-verified-email@example.com",
      "BookingPrice": "600"
    }
  }
}
```
4. Click **Test**
5. Check email inbox for confirmation

**Via Contact Flow:**
1. Make a test call with authenticated employee
2. Complete hotel booking via Lex
3. Check employee's email for confirmation
4. Verify booking price matches

## Variables

New variable in `terraform/variables.tf`:

```hcl
variable "ses_sender_email" {
  description = "Verified SES sender email"
  type        = string
  default     = "noreply@example.com"
}
```

## CI/CD Updates

GitHub Actions now creates all 3 Lambda packages:

```yaml
- name: Create Lambda Deployment Packages
  run: |
    cd terraform/modules/lambda-function
    python -m zipfile -c lambda_function.zip lambda_function.py

    cd ../lex-lambda-function
    python -m zipfile -c lambda_function.zip lambda_function.py

    cd ../ses-lambda-function
    python -m zipfile -c lambda_function.zip lambda_function.py
```

## Outputs

New Terraform outputs:

| Output | Description |
|--------|-------------|
| `ses_lambda_role_arn` | SES Lambda role ARN |
| `ses_lambda_function_name` | SES Lambda function name |
| `ses_lambda_function_arn` | SES Lambda ARN |

## Troubleshooting

**Email not received:**
- Verify sender email in SES Console
- Check recipient email is verified (if in sandbox)
- Review Lambda CloudWatch logs
- Check spam/junk folder

**"Email address is not verified" error:**
- Verify both sender and recipient in SES (sandbox mode)
- OR request production access
- Verify SENDER_EMAIL env variable matches verified address

**Lambda timeout:**
- SES calls are usually fast (<1 second)
- Check internet connectivity from Lambda VPC (if applicable)
- Review CloudWatch logs for SES errors

**HTML not rendering:**
- Some email clients block HTML
- Ensure proper HTML structure in template
- Test with different email clients

## SES Sandbox vs Production

| Feature | Sandbox | Production |
|---------|---------|------------|
| Recipient restrictions | Verified only | Any email |
| Daily limit | 200 emails | 50,000+ (scalable) |
| Rate limit | 1 email/sec | Higher |
| Cost | Same | Same |
| Approval | None | Request required |

**To exit sandbox:**
1. SES Console > Account dashboard
2. Click **Request production access**
3. Fill form with use case details
4. Approval in ~24 hours

## Email Customization

**Edit email template** in [lambda_function.py](terraform/modules/ses-lambda-function/lambda_function.py):

```python
message = f"""
<!DOCTYPE html>
<html>
<body style="font-family: Arial, sans-serif;">
  <h2>Hotel Booking Confirmation</h2>
  <p>Dear Valued Customer,</p>
  <p>Your hotel reservation has been confirmed!</p>
  <p><strong>Total Cost:</strong> ${booking_price}</p>
  <p>Thank you for choosing our service.</p>
  <footer>
    <p>The Employee Booking Team</p>
  </footer>
</body>
</html>
"""
```

**Add more parameters:**
- Location, CheckInDate, Nights from Lex
- Employee name from DynamoDB
- TripID for reference

## Differences from Previous Branch

| Feature | Amazon-Lex-Enhanced | Send-Email-Confirmation |
|---------|---------------------|------------------------|
| Employee Lambda/DDB | ✅ | ✅ (same) |
| Lex Lambda/DDB | ✅ | ✅ (same) |
| Email Confirmations | ❌ | ✅ SES Lambda |
| SES Integration | ❌ | ✅ |

## Next Steps

The main branch includes:
- Serverless CCP (S3/CloudFront hosting)
- Complete integration of all features

## Clean Up

```bash
terraform destroy
```

**Note:** Also manually delete:
- Lex bot
- Contact flows
- CloudWatch log groups
- SES verified identities (if no longer needed)

## Support

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Amazon SES Documentation](https://docs.aws.amazon.com/ses/)
- [SES Email Sending](https://docs.aws.amazon.com/ses/latest/dg/send-email.html)
- [AWS Lambda Python](https://docs.aws.amazon.com/lambda/latest/dg/lambda-python.html)
