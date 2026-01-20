# Hotel Booking Call Center - Custom CCP (Main Branch)

> **Branch**: `custom-ccp` (main)
> **Purpose**: Complete hotel booking system with serverless custom CCP deployment

Full-featured Amazon Connect hotel booking call center with custom Contact Control Panel (CCP) hosted on S3/CloudFront. This is the final integration of all features from previous branches.

## What's New in This Branch

**Added:**
- ✅ **S3 CCP Hosting** - S3 bucket for static website hosting
- ✅ **CloudFront Distribution** - CDN with HTTPS and OAI for secure CCP access
- ✅ **Custom CCP Files** - SimpleAgentConsole.html, ccp-integration.html, connect-streams API
- ✅ **Serverless CCP** - Fully hosted agent interface (no local server needed)

**Inherited from all previous branches:**
- 8 Contact Flows (Main, Transfer, Authentication, Whisper, Lex, etc.)
- Lex Bot (EmployeeBooking) with BookHotel intent
- Employee Lambda & DynamoDB (authentication)
- Lex Lambda & DynamoDB (hotel bookings)
- SES Lambda (email confirmations)
- Hours of Operation, Queues, Routing Profile, Agent User

## Repository Structure

```
.
├── Contact Flows/                    # 8 contact flows
├── Lex Bots/                         # EmployeeBooking bot
├── custom-ccp/                       # NEW: Custom CCP files
│   ├── ccp-integration.html          # Event logging CCP
│   ├── connect-streams-min.js        # Streams API v2.22.0
│   └── serverless-ccp/               # Files for S3 deployment
│       ├── SimpleAgentConsole.html   # Agent console
│       ├── ccp.html                  # Basic CCP
│       └── connect-streams-min.js
├── terraform/
│   └── modules/
│       ├── s3-ccp-hosting/           # NEW: S3 bucket
│       ├── cloudfront-ccp/           # NEW: CloudFront CDN
│       ├── ses-lambda-role/
│       ├── ses-lambda-function/
│       ├── lex-lambda-function/
│       ├── lex-dynamodb-table/
│       ├── lambda-role/
│       ├── dynamodb-table/
│       ├── lambda-function/
│       └── ...
└── .github/workflows/
```

## New Infrastructure Components

### 1. S3 CCP Hosting
**Module**: s3-ccp-hosting

**Purpose**: Hosts custom CCP static files

**Configuration:**
- Public access blocked (CloudFront uses OAI)
- Website hosting disabled (served via CloudFront)
- Stores: SimpleAgentConsole.html, ccp.html, connect-streams-min.js

### 2. CloudFront Distribution
**Module**: cloudfront-ccp

**Purpose**: Secure HTTPS access to CCP with global CDN

**Configuration:**
- Default root object: SimpleAgentConsole.html
- Origin Access Identity (OAI) for S3 access
- HTTPS redirect enforced
- Cache TTL: 60s default, 1 day max
- Price class: PriceClass_100 (North America & Europe)
- Compression enabled

**CloudFront Settings:**
- Allowed methods: GET, HEAD, OPTIONS
- CORS headers forwarded
- Query strings forwarded
- IPv6 enabled

## Custom CCP Features

### SimpleAgentConsole.html
**Features:**
- Two-panel layout (CCP + Contact Info)
- Real-time agent status display
- Contact details (phone, queue, attributes)
- Connection history tracking
- Professional UI with AWS styling

**Agent Events Tracked:**
- Connection/disconnection
- State changes (Available, Offline, ACW)
- Routable status changes
- After Call Work (ACW) events

**Contact Events Tracked:**
- Incoming/outgoing calls
- Contact accepted/connected/ended
- Contact attributes display
- Queue information

### ccp-integration.html
**Features:**
- Event logging panel
- Detailed agent and contact event display
- Useful for debugging and monitoring
- Real-time event stream

## Deployment

### 1. Deploy Infrastructure

```bash
git checkout custom-ccp  # or main
cd terraform
terraform init -backend-config=backend.hcl
terraform apply
```

**New Resources Created:**
- S3 bucket for CCP hosting
- CloudFront distribution with OAI
- S3 bucket policy for CloudFront access

**Get CloudFront URL:**
```bash
terraform output cloudfront_domain_name
```

### 2. Upload CCP Files to S3

**Manual Upload:**
```bash
# Get bucket name from Terraform output
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# Upload files
aws s3 cp custom-ccp/serverless-ccp/ s3://$BUCKET_NAME/ --recursive
```

**Files uploaded:**
- SimpleAgentConsole.html
- ccp.html
- connect-streams-min.js

### 3. Configure Amazon Connect Approved Origins

**Critical Step** - Without this, CCP won't load.

1. Go to AWS Console > Amazon Connect
2. Select your instance
3. Click **Approved origins** (left menu)
4. Click **Add origin**
5. Add CloudFront domain: `https://<cloudfront-id>.cloudfront.net`
6. Save

**Example:**
```
https://d1a2b3c4d5e6f7.cloudfront.net
```

### 4. Update CCP Configuration

**Edit uploaded files** (or before upload):

In SimpleAgentConsole.html and ccp.html, update:

```javascript
connect.core.initCCP(document.getElementById("ccpDiv"), {
    ccpUrl: "https://YOUR-INSTANCE-NAME.my.connect.aws/ccp-v2",
    region: "us-east-1",  // Your region
    loginPopup: true,
    softphone: {
        allowFramedSoftphone: true
    }
});
```

**To find your CCP URL:**
1. AWS Console > Amazon Connect
2. Click instance name
3. Overview tab > Access URL
4. Append `/ccp-v2` to the URL

### 5. Access Custom CCP

Open CloudFront URL in browser:
```
https://<cloudfront-id>.cloudfront.net/SimpleAgentConsole.html
```

**First Time:**
1. Login popup appears
2. Enter agent credentials (e.g., pelekengaih)
3. CCP initializes
4. Agent status shows in left panel
5. Set status to "Available"

## Testing End-to-End Flow

### Test Complete Hotel Booking

1. **Agent Login:**
   - Open CloudFront CCP URL
   - Login as agent (pelekengaih)
   - Set status to "Available"

2. **Make Test Call:**
   - Call Amazon Connect phone number
   - System plays welcome message

3. **Employee Authentication:**
   - Enter Employee ID: 101
   - Enter PIN: 111
   - Lambda validates credentials

4. **Lex Hotel Booking:**
   - Say "Book a hotel"
   - Lex asks: Where? "New York"
   - When? "2026-01-25"
   - How many nights? "3"
   - Confirm booking

5. **Email Confirmation:**
   - SES Lambda sends email to pelekengaih@gmail.com
   - Email contains booking price
   - Booking stored in LexBookHotel DynamoDB

6. **Agent Whisper:**
   - Agent hears employee name
   - Call connects to agent
   - Agent assists if needed

## Variables

New variables in `terraform/variables.tf`:

```hcl
variable "s3_bucket_name" {
  description = "S3 bucket name for CCP hosting"
  type        = string
}

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
}
```

## Outputs

New Terraform outputs:

| Output | Description |
|--------|-------------|
| `s3_bucket_name` | S3 bucket name |
| `s3_bucket_arn` | S3 bucket ARN |
| `cloudfront_domain_name` | CloudFront URL (use this to access CCP) |
| `cloudfront_distribution_id` | CloudFront distribution ID |

**Get outputs:**
```bash
terraform output
```

## Troubleshooting

### CCP Not Loading

**"Unable to load CCP" error:**
- Verify CloudFront domain is in Amazon Connect Approved Origins
- Check browser console for CORS errors
- Ensure ccpUrl is correct in HTML files

**Login popup doesn't appear:**
- Clear browser cache and cookies
- Try incognito/private mode
- Check CloudFront distribution is deployed (Status: Deployed)

### CloudFront Issues

**404 Not Found:**
- Verify files uploaded to S3 bucket
- Check S3 bucket has OAI policy
- Wait 5-10 minutes for CloudFront propagation

**Access Denied:**
- Check S3 bucket policy allows CloudFront OAI
- Verify CloudFront origin is configured correctly

### CCP Configuration

**CCP loads but can't connect:**
- Verify ccpUrl in HTML matches your instance
- Check region setting matches instance region
- Ensure agent user exists and has correct permissions

## Architecture Overview

```
User Browser
    │
    ├─► CloudFront (HTTPS)
    │       │
    │       └─► S3 Bucket (via OAI)
    │               │
    │               └─► SimpleAgentConsole.html
    │                       │
    │                       └─► Amazon Connect Streams API
    │                               │
    └─────────────────────────────► Amazon Connect Instance
                                        │
                                        ├─► Contact Flows
                                        ├─► Employee Lambda (auth)
                                        ├─► Lex Bot (booking)
                                        ├─► Lex Lambda (fulfillment)
                                        └─► SES Lambda (email)
```

## Custom CCP vs Default CCP

| Feature | Default CCP | Custom CCP (This Branch) |
|---------|-------------|--------------------------|
| Hosting | AWS Managed | S3 + CloudFront |
| Customization | Limited | Full HTML/CSS/JS control |
| Branding | Amazon Connect | Custom styling |
| Contact Details | Basic view | Enhanced display with attributes |
| Event Logging | None | Available in ccp-integration.html |
| Deployment | None needed | Terraform automated |

## Cost Considerations

**S3:**
- Storage: ~$0.023/GB (minimal - few HTML/JS files)
- Requests: Negligible (CloudFront caches)

**CloudFront:**
- PriceClass_100: North America & Europe only (cheapest)
- Data transfer: First 1TB free tier
- Requests: First 10M free tier
- Estimated: $1-5/month for small teams

**Lambda, SES, DynamoDB:**
- See previous branch READMEs

## Security Best Practices

1. **HTTPS Only**: CloudFront enforces HTTPS redirect
2. **OAI Access**: S3 bucket not publicly accessible
3. **CORS**: Only approved origins can embed CCP
4. **No Secrets**: No API keys or credentials in HTML files
5. **IAM Roles**: Lambda functions use least privilege roles

## Next Steps

**Enhancements:**
- Add custom domain to CloudFront (requires ACM certificate)
- Implement additional contact attributes display
- Add call recording controls
- Integrate with external CRM
- Add analytics dashboard

## Clean Up

```bash
# Empty S3 bucket first (CloudFront must be disabled)
aws s3 rm s3://$(terraform output -raw s3_bucket_name) --recursive

# Destroy infrastructure
terraform destroy
```

**Note:** Also manually delete:
- Lex bot
- Contact flows
- CloudWatch log groups
- SES verified identities

CloudFront distributions take 15-30 minutes to fully delete.

## Complete Feature List

This branch includes ALL features:

| Feature | Status |
|---------|--------|
| Contact Flows (8) | ✅ |
| Hours of Operation | ✅ |
| Queues (2) | ✅ |
| Routing Profile | ✅ |
| Agent User | ✅ |
| Lex Bot (EmployeeBooking) | ✅ |
| Employee Lambda & DynamoDB | ✅ |
| Lex Lambda & DynamoDB | ✅ |
| SES Lambda & Email | ✅ |
| Custom CCP (S3/CloudFront) | ✅ |
| CI/CD (GitHub Actions) | ✅ |

## Support

- [Amazon Connect Streams API](https://github.com/amazon-connect/amazon-connect-streams)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [Connect Custom CCP Guide](https://docs.aws.amazon.com/connect/latest/adminguide/amazon-connect-streams.html)
