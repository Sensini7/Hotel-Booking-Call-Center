# Hotel Booking Call Center - Amazon Lex Integration

> **Branch**: `Amazon-Lex-Integration`
> **Purpose**: Add conversational AI for hotel booking using Amazon Lex V2

Adds Amazon Lex bot for natural language hotel reservations. Builds on the `receiving-First-Call` foundation.

## What's New in This Branch

**Added:**
- ✅ Amazon Lex bot (EmployeeBooking) with 3 intents
- ✅ BookHotel intent - Collects location, check-in date, nights
- ✅ AgentSupport intent - Escalates to human agent
- ✅ FallbackIntent - Handles unrecognized input

**Inherited from `receiving-First-Call`:**
- Contact Flows (3 flows)
- Hours of Operation, Queues, Routing Profile, Agent User

**Not Yet Included:**
- Lambda functions (next branch)
- DynamoDB tables (next branch)
- SES email (later branch)
- Custom CCP (later branch)

## Repository Structure

```
.
├── Contact Flows/
│   ├── EmployeeBooking_MainFlow.json
│   ├── EmployeeBooking_TransferToQueue.json
│   └── Default customer queue.json
├── Lex Bots/                               # NEW: Lex bot files
│   ├── EmployeeBooking/                    # Bot source (JSON)
│   ├── EmployeeBooking-...-LexJson.zip     # Full export
│   ├── ...-nopassword.zip                  # Export (no password)
│   └── Manifest.json
├── terraform/                              # Same as previous branch
└── .github/workflows/
```

## Lex Bot: EmployeeBooking

**Bot Details:**
- Version: 1
- Session Timeout: 60 seconds
- Language: English (US)

### Intents

#### 1. BookHotel
Main intent for booking reservations.

**Slots (in order):**
1. **Location** (City) - "What city will you be staying in?"
2. **CheckInDate** (Date) - "What date do you want to check in?"
3. **Nights** (Number) - "How many nights will you be staying?"

**Confirmation:** "Okay, I have you down for a {Nights} night stay in {Location} starting {CheckInDate}. Shall I book the reservation?"

**Response:** "Thanks, I have placed your reservation."

**Code Hooks:** Enabled (not configured yet - added in later branch)

#### 2. AgentSupport
Transfers to human agent.

**Sample Utterances:** "I need to speak to an agent", "Transfer me to a representative"

#### 3. FallbackIntent
Catch-all for unrecognized input.

### Conversation Example

```
User: "Book a hotel"
Bot:  "What city will you be staying in?"
User: "New York"
Bot:  "What date do you want to check in?"
User: "Tomorrow"
Bot:  "How many nights will you be staying?"
User: "3"
Bot:  "Okay, I have you down for a 3 night stay in New York
       starting tomorrow. Shall I book the reservation?"
User: "Yes"
Bot:  "Thanks, I have placed your reservation."
```

## Deployment

### 1. Deploy Infrastructure (Same as Previous Branch)

```bash
git checkout Amazon-Lex-Integration
cd terraform
terraform init -backend-config=backend.hcl
terraform apply
```

### 2. Import Contact Flows

Same as previous branch - import 3 flows via Amazon Connect Console.

### 3. Import Lex Bot (Manual)

**Via Lex Console:**

1. Go to [Amazon Lex Console](https://console.aws.amazon.com/lexv2/)
2. **Bots** > **Create bot** > **Import**
3. Upload: `Lex Bots/EmployeeBooking-1-UAZCNPD9XP-LexJson-nopassword.zip`
4. Click **Import** (wait 1-2 minutes)
5. Click **Build** to build the bot
6. Create an **Alias** (e.g., "Production")

**Via AWS CLI:**

```bash
aws lexv2-models create-bot-import \
  --bot-import-specification file://Lex\ Bots/EmployeeBooking-1-UAZCNPD9XP-LexJson-nopassword.zip \
  --region us-east-1
```

### 4. Connect Lex Bot to Amazon Connect

1. Go to **Amazon Connect Console** > Your instance
2. **Contact flows** > **Amazon Lex**
3. **+ Add Lex bot**
4. Select bot: **EmployeeBooking**, Alias: **Production**
5. **Add Amazon Lex Bot**

**Note:** Connect service role needs Lex invoke permissions.

### 5. Update Contact Flow (Optional)

Add **Get customer input** block to contact flow:
- Select **Amazon Lex**
- Bot: EmployeeBooking
- Alias: Production
- Route based on intent responses

### 6. Test

**In Lex Console:**
- Test tab > "I want to book a hotel"

**Via Phone:**
- Call your Connect number
- Say "Book a hotel"
- Follow prompts for location, date, nights
- Confirm booking

## Files

- **EmployeeBooking-1-NJUOWXPAMP-LexJson.zip** - Full bot export
- **EmployeeBooking-1-UAZCNPD9XP-LexJson-nopassword.zip** - No password (recommended)
- **EmployeeBooking/** - Bot source files (JSON format)
- **Manifest.json** - Export metadata

## Troubleshooting

**Bot not in Connect "Add Lex bot" list:**
- Verify bot is built and has an alias
- Check same region (us-east-1)
- Verify Connect role has Lex permissions

**Bot doesn't understand utterances:**
- Ensure bot is built (not just saved)
- Test in Lex Console first
- Rebuild after any changes

**Code hook errors:**
- Hooks are enabled but not configured
- Disable in intent settings, or add Lambda (next branch)

**Cannot import bot:**
- Use the `-nopassword` zip file
- Check region is us-east-1
- Verify IAM permissions

## Required IAM Permissions

Add to your Terraform role for Lex operations:

```json
{
  "Sid": "LexPermissions",
  "Effect": "Allow",
  "Action": [
    "lex:*",
    "connect:AssociateLexBot",
    "connect:DisassociateLexBot"
  ],
  "Resource": "*"
}
```

## Differences from Previous Branch

| Feature | receiving-First-Call | Amazon-Lex-Integration |
|---------|---------------------|------------------------|
| Contact Flows | ✅ | ✅ (same) |
| Lex Bot | ❌ | ✅ EmployeeBooking |
| Conversational AI | ❌ | ✅ |
| Lambda/DynamoDB | ❌ | ❌ (next branch) |

## Next Steps

Next branches add:
1. Lambda functions (validation, fulfillment)
2. DynamoDB tables (employee, booking data)
3. SES email confirmations
4. Serverless CCP (S3/CloudFront)

## Clean Up

**Terraform:**
```bash
terraform destroy
```

**Manual:**
- Delete Lex bot (Lex Console)
- Delete contact flows (Connect Console)

## Support

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Amazon Connect Docs](https://docs.aws.amazon.com/connect/)
- [Amazon Lex V2 Docs](https://docs.aws.amazon.com/lexv2/)
