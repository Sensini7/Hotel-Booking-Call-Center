# Hotel Booking Call Center - Amazon Lex Integration

> **Branch**: `Amazon-Lex-Integration`
> **Purpose**: Add conversational AI hotel booking capabilities using Amazon Lex V2

This branch builds upon the `receiving-First-Call` foundation by adding Amazon Lex bot integration for conversational hotel booking. Callers can now interact with an AI-powered voice assistant to book hotel reservations through natural language.

## What This Branch Adds

This is the **second phase** of the project that adds:

1. ✅ **Amazon Lex Bot** - AI-powered conversational interface for hotel bookings
2. ✅ **BookHotel Intent** - Natural language understanding for hotel reservation requests
3. ✅ **Slot Collection** - Captures location, check-in date, and number of nights
4. ✅ **Confirmation Flow** - Reviews booking details before confirming
5. ✅ **Agent Support Intent** - Escalates complex requests to human agents

**Inherited from previous branch:**
- Contact Flows (Main Flow, Transfer to Queue, Default customer queue)
- Hours of Operation
- Call Queues (Authenticated and Unknown)
- Routing Profile
- Agent User

**What's NOT yet in this branch:**
- Lambda functions for database lookups (comes in later branches)
- DynamoDB tables for employee and booking data
- SES email notifications
- Custom CCP hosting (S3/CloudFront)

## Repository Structure

```
.
├── Contact Flows/                          # Pre-configured contact flows
│   ├── EmployeeBooking_MainFlow.json
│   ├── EmployeeBooking_TransferToQueue.json
│   └── Default customer queue.json
├── Lex Bots/                               # Amazon Lex bot definitions
│   ├── EmployeeBooking/                    # Bot source files (JSON)
│   │   ├── Bot.json                        # Main bot configuration
│   │   └── BotLocales/
│   │       └── en_US/                      # English (US) locale
│   │           ├── BotLocale.json
│   │           └── Intents/
│   │               ├── BookHotel/          # Hotel booking intent
│   │               ├── AgentSupport/       # Escalation to agent
│   │               └── FallbackIntent/     # Catch-all fallback
│   ├── EmployeeBooking-1-NJUOWXPAMP-LexJson.zip          # Full bot export
│   ├── EmployeeBooking-1-UAZCNPD9XP-LexJson-nopassword.zip  # No password variant
│   └── Manifest.json                       # Bot manifest metadata
├── terraform/
│   ├── modules/
│   │   ├── hours-of-operation/
│   │   ├── queue/
│   │   ├── routing-profile/
│   │   └── user/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   └── provider.tf
├── .github/
│   └── workflows/
│       └── receiving-first-call.yml
└── README.md                               # This file
```

## Amazon Lex Bot

### Bot Overview: EmployeeBooking

**Name**: EmployeeBooking
**Version**: 1
**Description**: Prod Version 1
**Session Timeout**: 60 seconds
**Child Directed**: No

The EmployeeBooking bot provides conversational AI for hotel booking through voice and text channels in Amazon Connect.

### Intents

#### 1. BookHotel Intent
**Purpose**: Main intent for booking hotel reservations

**Sample Utterances:**
- "Book a hotel"
- "I want to make hotel reservations"
- "Book a {Nights} night stay in {Location}"

**Slots (collected in priority order):**
1. **Location** (Priority 1)
   - Type: AMAZON.City or custom city list
   - Prompt: "What city will you be staying in?"
   - Required: Yes

2. **CheckInDate** (Priority 2)
   - Type: AMAZON.Date
   - Prompt: "What date do you want to check in?"
   - Required: Yes

3. **Nights** (Priority 3)
   - Type: AMAZON.Number
   - Prompt: "How many nights will you be staying?"
   - Required: Yes

**Confirmation Prompt:**
```
"Okay, I have you down for a {Nights} night stay in {Location}
starting {CheckInDate}. Shall I book the reservation?"
```

**Responses:**
- **On Confirmation**: "Thanks, I have placed your reservation."
- **On Declination**: "Okay, I have canceled your reservation in progress."

**Code Hooks:**
- **Initialization Hook**: Enabled (validates inputs)
- **Fulfillment Hook**: Enabled (processes booking)
- **Elicitation Hook**: Enabled (validates during slot collection)

**Failure Handling:**
- Escalates to FallbackIntent after multiple failures
- Maximum 4 retry attempts for confirmations

#### 2. AgentSupport Intent
**Purpose**: Escalate to human agent for complex requests

**Sample Utterances:**
- "I need to speak to an agent"
- "Can I talk to a person?"
- "Transfer me to a representative"

**Action**: Transfers call to agent queue

#### 3. FallbackIntent
**Purpose**: Catch-all for unrecognized inputs

**Action**: Provides help message or transfers to agent

### Bot Settings

**Audio & DTMF Input:**
- Start timeout: 4000ms
- End timeout: 5000ms (DTMF)
- Audio end timeout: 640ms
- Max audio length: 15000ms
- DTMF deletion character: *
- DTMF end character: #

**Text Input:**
- Start timeout: 30000ms

**Session Management:**
- Idle session TTL: 60 seconds
- Error logging: Disabled (can be enabled for debugging)

## Quick Start

### Prerequisites

- AWS Account with Amazon Connect instance in `us-east-1`
- Terraform >= 1.6.0
- AWS CLI configured
- S3 bucket for Terraform state
- GitHub repository secrets configured (for CI/CD)
- **Amazon Lex V2 permissions** in IAM role

### Deployment Steps

#### 1. Deploy Infrastructure (Same as Previous Branch)

```bash
git checkout Amazon-Lex-Integration
cd terraform

# Initialize and deploy
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

#### 2. Import Contact Flows

Follow the same process as `receiving-First-Call` branch:

1. Go to Amazon Connect Console > **Routing** > **Contact flows**
2. Import all 3 contact flows from `Contact Flows/` directory
3. Publish each flow
4. Assign `EmployeeBooking_MainFlow` to your phone number

#### 3. Import Lex Bot

**Option A: Import via Amazon Lex Console (Recommended)**

1. Go to **Amazon Lex Console** (https://console.aws.amazon.com/lexv2/)
2. Click **Bots** > **Create bot**
3. Select **Import**
4. Upload `Lex Bots/EmployeeBooking-1-NJUOWXPAMP-LexJson.zip`
5. Choose a name (e.g., "EmployeeBooking")
6. Select **Create role** or choose existing Lex role
7. Click **Import**
8. Wait for import to complete (may take 1-2 minutes)
9. Click **Build** to build the bot
10. Create an **Alias** (e.g., "Production")

**Option B: Import via AWS CLI**

```bash
# Create bot from zip file
aws lexv2-models create-bot-import \
  --bot-import-specification file://Lex\ Bots/EmployeeBooking-1-NJUOWXPAMP-LexJson.zip \
  --region us-east-1

# Check import status
aws lexv2-models describe-bot-import \
  --import-id <IMPORT_ID> \
  --region us-east-1

# Build the bot after import
aws lexv2-models build-bot-locale \
  --bot-id <BOT_ID> \
  --bot-version DRAFT \
  --locale-id en_US \
  --region us-east-1
```

#### 4. Integrate Lex Bot with Amazon Connect

1. Go to **Amazon Connect Console**
2. Select your instance
3. In the left menu, click **Contact flows**
4. Under **Amazon Lex**, click **+ Add Lex bot**
5. Select:
   - **Bot name**: EmployeeBooking
   - **Alias**: Production (or the alias you created)
6. Click **Add Amazon Lex Bot**

**Important**: The Connect instance service role must have permissions to invoke Lex.

#### 5. Create Contact Flow with Lex Integration

Create a new contact flow or modify existing:

1. Go to **Routing** > **Contact flows** > **Create contact flow**
2. Add a **Get customer input** block
3. Configure the block:
   - Select **Amazon Lex**
   - **Bot**: EmployeeBooking
   - **Alias**: Production
   - **Intent**: BookHotel
4. Add routing based on intent responses:
   - **Fulfilled**: Play success message
   - **Failed**: Transfer to agent
   - **AgentSupport**: Transfer to queue
5. Save and publish

**Example Flow:**
```
Entry
  │
  ├─► Set working queue
  ├─► Get customer input (Lex: BookHotel)
  │   │
  │   ├─► Fulfilled ──► Play confirmation ──► End
  │   ├─► Failed ──► Transfer to agent
  │   └─► AgentSupport ──► Transfer to agent queue
```

#### 6. Test the Bot

**Test in Lex Console:**
1. Go to Lex Console > Your bot > **Test**
2. Try sample utterances:
   - "I want to book a hotel"
   - "Book a 3 night stay in New York"
3. Verify slot collection and confirmation

**Test via Amazon Connect:**
1. Call your Connect phone number
2. Say "Book a hotel"
3. Follow the prompts to provide:
   - Location (city)
   - Check-in date
   - Number of nights
4. Confirm the booking
5. Verify success message

## Lex Bot Details

### Conversation Flow

```
User: "Book a hotel"
Bot: "What city will you be staying in?"
User: "New York"
Bot: "What date do you want to check in?"
User: "Tomorrow"
Bot: "How many nights will you be staying?"
User: "3"
Bot: "Okay, I have you down for a 3 night stay in New York
      starting tomorrow. Shall I book the reservation?"
User: "Yes"
Bot: "Thanks, I have placed your reservation."
```

### Slot Validation

The bot performs basic validation:

**Location:**
- Accepts city names
- No special validation in this version
- Future: Validate against supported cities

**CheckInDate:**
- Uses AMAZON.Date slot type
- Handles relative dates ("tomorrow", "next Monday")
- Handles absolute dates ("January 25th", "12/25/2024")
- Future: Validate date is not in the past

**Nights:**
- Uses AMAZON.Number slot type
- Accepts numeric values
- Future: Validate range (1-30 nights)

### Error Handling

**Unrecognized Input:**
- After 4 failed attempts, escalates to FallbackIntent
- FallbackIntent offers to transfer to agent

**Timeout:**
- Voice: 4 seconds start timeout
- Text: 30 seconds start timeout
- On timeout, reprompts or escalates to agent

**Declination:**
- User says "No" during confirmation
- Bot cancels reservation
- Ends conversation gracefully

## Customization

### Add More Cities

Edit the Location slot type in Lex Console:

1. Go to Bot > Intents > BookHotel > Slots > Location
2. Add custom slot type values:
   - New York
   - Los Angeles
   - Chicago
   - (add more cities)
3. Rebuild the bot

### Change Confirmation Message

1. Go to Intents > BookHotel > Confirmation
2. Edit prompt: "Okay, I have you down for..."
3. Rebuild the bot

### Add Lambda Validation (Future Enhancement)

The bot has code hooks enabled but not yet configured:

1. Create Lambda function for validation
2. Attach to BookHotel intent initialization hook
3. Validate:
   - Date is not in the past
   - Nights between 1-30
   - City is in supported list

**Note**: Lambda integration is added in a later branch.

## CI/CD with GitHub Actions

### Required GitHub Secrets

Same as previous branch:

| Secret | Description |
|--------|-------------|
| `AWS_ROLE_ARN` | IAM role ARN for OIDC |
| `TF_STATE_BUCKET` | S3 bucket for state |
| `CONNECT_INSTANCE_ID` | Connect instance ID |
| `INSTANCE_PHONE_NUMBER_ID` | Phone number ARN |
| `USER_PASSWORD` | Agent password |

**Additional IAM Permissions Needed:**

```json
{
  "Sid": "LexPermissions",
  "Effect": "Allow",
  "Action": [
    "lex:CreateBot",
    "lex:DeleteBot",
    "lex:UpdateBot",
    "lex:DescribeBot",
    "lex:ListBots",
    "lex:BuildBotLocale",
    "lex:CreateBotAlias",
    "lex:DeleteBotAlias",
    "lex:UpdateBotAlias",
    "connect:AssociateLexBot",
    "connect:DisassociateLexBot",
    "connect:ListLexBots"
  ],
  "Resource": "*"
}
```

### Workflow

The GitHub Actions workflow runs the same as previous branch:

1. Manual trigger required
2. Terraform plan and validate
3. Wait for production environment approval
4. Apply infrastructure

**Note**: Lex bot import is still manual in this branch.

## Outputs

Terraform outputs (same as previous branch):

| Output | Description |
|--------|-------------|
| `hours_of_operation_id` | Hours of operation ID |
| `authenticated_queue_arn` | Authenticated queue ARN |
| `routing_profile_id` | Routing profile ID |
| `user_id` | Agent user ID |

## Troubleshooting

### Issue: Lex bot not available in Connect

**Error**: Bot doesn't appear in "Add Lex bot" list

**Solution**:
1. Verify bot is built and has an alias
2. Check bot and Connect instance are in same region
3. Verify Connect service role has Lex permissions:
```bash
aws iam get-role --role-name AmazonConnect-<InstanceAlias>
```

### Issue: Bot doesn't understand utterances

**Error**: Always falls to FallbackIntent

**Solution**:
1. Check bot is built (not just saved)
2. Verify sample utterances are added to BookHotel intent
3. Test in Lex Console first before Connect
4. Rebuild the bot after any changes

### Issue: Code hook errors

**Error**: "Lambda function error" or code hook timeout

**Solution**:
1. Code hooks are enabled but not configured in this branch
2. Either:
   - Disable code hooks in intent settings, or
   - Create Lambda functions (added in later branch)

### Issue: Slot values not captured

**Error**: Bot keeps asking for same slot

**Solution**:
1. Check slot type is correct (AMAZON.Date, AMAZON.Number, etc.)
2. Verify slot prompts are configured
3. Test with specific values (not vague responses)
4. Check slot priority order

### Issue: Cannot import bot

**Error**: "Import failed" or "Invalid bot definition"

**Solution**:
1. Use the `-nopassword` version of the zip file
2. Verify you're in the correct AWS region (us-east-1)
3. Check IAM permissions for Lex operations
4. Try importing via Console instead of CLI

## Differences from Previous Branch

| Feature | receiving-First-Call | Amazon-Lex-Integration |
|---------|---------------------|------------------------|
| Contact Flows | ✅ 3 flows | ✅ 3 flows (same) |
| Lex Bot | ❌ None | ✅ EmployeeBooking bot |
| Intents | ❌ N/A | ✅ BookHotel, AgentSupport, Fallback |
| Conversational AI | ❌ No | ✅ Yes |
| Lambda Functions | ❌ No | ❌ No (next branch) |
| DynamoDB | ❌ No | ❌ No (next branch) |

## Next Steps

After this branch is deployed, the next phases add:

1. **Lambda Functions** - Validation and fulfillment hooks for Lex
2. **DynamoDB Tables** - Store employee data and booking records
3. **SES Email** - Send booking confirmations
4. **Serverless CCP** - Custom CCP on S3/CloudFront

See later branches for these features.

## Clean Up

### Via GitHub Actions
1. Go to **Actions** > **receiving first call workflow**
2. Run workflow
3. Approve the **destroy** job

### Via Local Terraform
```bash
cd terraform
terraform destroy
```

### Manual Cleanup
Also delete:
- Lex bot (Amazon Lex Console)
- Contact flows (Amazon Connect Console)

## Files Reference

### Bot Export Files

- **EmployeeBooking-1-NJUOWXPAMP-LexJson.zip**: Full bot export with all intents, slots, and configurations
- **EmployeeBooking-1-UAZCNPD9XP-LexJson-nopassword.zip**: Bot export without password protection (easier import)
- **Manifest.json**: Metadata about the bot export

### Bot Source Structure

```
EmployeeBooking/
├── Bot.json                    # Main bot configuration
└── BotLocales/
    └── en_US/
        ├── BotLocale.json      # Locale settings
        └── Intents/
            ├── BookHotel/
            │   ├── Intent.json
            │   └── Slots/
            │       ├── Location/Slot.json
            │       ├── CheckInDate/Slot.json
            │       └── Nights/Slot.json
            ├── AgentSupport/
            │   └── Intent.json
            └── FallbackIntent/
                └── Intent.json
```

## Contributing

1. Create a feature branch from `Amazon-Lex-Integration`
2. Make your changes
3. Test locally
4. Submit a pull request

## Support

For issues with:
- **Terraform**: [Terraform AWS Provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- **Amazon Connect**: [AWS Connect documentation](https://docs.aws.amazon.com/connect/)
- **Amazon Lex**: [Lex V2 documentation](https://docs.aws.amazon.com/lexv2/)
- **Bot Building**: [Lex Bot Builder Guide](https://docs.aws.amazon.com/lexv2/latest/dg/)
- **This Project**: Open an issue in the repository

## License

This project is provided as-is for use with Amazon Connect and Amazon Lex.
