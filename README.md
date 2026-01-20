# Hotel Booking Call Center - Dynamic Contact Flow

> **Branch**: `Dynamic-Contact-Flow`
> **Purpose**: Add Lambda and DynamoDB for employee authentication and dynamic call routing

Adds database-driven employee lookup with PIN authentication. Builds on `Amazon-Lex-Integration`.

## What's New in This Branch

**Added:**
- ✅ **New Contact Flows** - 4 flows for Lambda integration and authentication
- ✅ **Lambda IAM Role** - Permissions for DynamoDB and CloudWatch Logs
- ✅ **DynamoDB Employee Table** - Stores employee data with PhoneNumber GSI
- ✅ **Lambda Function** (EmployeeBooking_DBLookup) - Employee lookup and PIN validation
- ✅ **Test Events** - 5 Lambda test scenarios

**Inherited from previous branches:**
- Original 3 Contact Flows, Lex Bot (EmployeeBooking)
- Hours of Operation, Queues, Routing Profile, Agent User

**Not Yet Included:**
- Lex Lambda integration (next branch)
- SES email (later branch)
- Custom CCP (later branch)

## Repository Structure

```
.
├── Contact Flows/                      # 8 total flows
│   ├── Default customer queue.json
│   ├── EmployeeBooking_MainFlow.json
│   ├── EmployeeBooking_TransferToQueue.json
│   ├── EmployeeBooking_AgentWhisper.json               # NEW
│   ├── EmployeeBooking_Authentication.json             # NEW
│   ├── EmployeeBooking_LexBot.json                     # NEW
│   ├── EmployeeBooking_MainFlow_lexintegration.json    # NEW
│   └── EmployeeBooking_TransferToQueue_WhisperflowIntegrated.json  # NEW
├── Lex Bots/
├── terraform/
│   └── modules/
│       ├── lambda-role/                # NEW: Lambda IAM role
│       ├── dynamodb-table/             # NEW: Employee table
│       ├── lambda-function/            # NEW: DB lookup function
│       │   ├── lambda_function.py
│       │   ├── lambda_function.zip
│       │   └── test-events/            # 5 test scenarios
│       ├── hours-of-operation/
│       ├── queue/
│       ├── routing-profile/
│       └── user/
└── .github/workflows/
```

## New Contact Flows

### 1. EmployeeBooking_Authentication
**Purpose**: Employee authentication using Lambda DBLookup

**Flow Logic:**
- Retrieves caller phone number
- Invokes Lambda with phone number
- Branches based on EmployeeType:
  - AUTHENTICATED (1) → Sets employee attributes, continues
  - PIN_REQUIRED (2) → Prompts for PIN, re-invokes Lambda
  - UNKNOWN (0) → Proceeds as unknown caller
  - INCORRECT_PIN (3) → Proceeds as unknown caller

### 2. EmployeeBooking_AgentWhisper
**Purpose**: Whisper employee information to agent before connecting

**Flow Logic:**
- Plays employee name to agent
- Plays "Connecting now" message
- Returns to main flow

### 3. EmployeeBooking_LexBot
**Purpose**: Hotel booking using Lex bot

**Flow Logic:**
- Invokes Lex bot (EmployeeBooking)
- Handles BookHotel intent responses
- Transfers to agent on failure

### 4. EmployeeBooking_MainFlow_lexintegration
**Purpose**: Updated main flow with Lex integration

**Flow Logic:**
- Welcome message
- Calls Authentication flow
- If authenticated → Calls LexBot flow
- If unknown → Transfers to Unknown queue

### 5. EmployeeBooking_TransferToQueue_WhisperflowIntegrated
**Purpose**: Transfer to queue with agent whisper

**Flow Logic:**
- Checks hours of operation
- If authenticated → Calls AgentWhisper, transfers to Authenticated queue
- If unknown → Transfers to Unknown queue

## New Infrastructure Components

### 1. Lambda IAM Role
**Name**: Lambda_EmployeeBooking

**Permissions:**
- DynamoDB: GetItem, PutItem, Scan, Query
- CloudWatch Logs: CreateLogGroup, CreateLogStream, PutLogEvents

### 2. DynamoDB Table
**Name**: Employee

**Schema:**
- **Partition Key**: EmployeeID (String)
- **GSI**: PhoneNumber-index
  - Partition Key: PhoneNumber (String)
  - Projection: ALL

**Sample Item:**
```json
{
  "EmployeeID": "101",
  "EmployeePIN": "111",
  "EmailAddress": "pelekengaih@gmail.com",
  "EmployeeName": "Peleke Ngaih",
  "PhoneNumber": "+18285282177"
}
```

### 3. Lambda Function
**Name**: EmployeeBooking_DBLookup
**Runtime**: Python 3.12
**Memory**: 256 MB
**Timeout**: 7 seconds

**Purpose**: Lookup employee by phone number or employee ID, validate PIN

**Input Parameters:**
- `PhoneNumber` (optional) - Caller's phone number
- `EmployeeID` (optional) - Employee ID for manual entry
- `EmployeePIN` (optional) - PIN for authentication

**Return Values:**
- `EmployeeType`:
  - `0` = UNKNOWN (no match found)
  - `1` = AUTHENTICATED (PIN correct)
  - `2` = PIN_REQUIRED (employee found, needs PIN)
  - `3` = INCORRECT_PIN (PIN mismatch)
- `EmployeeID` - Matched employee ID
- `EmployeeName` - Employee's full name

**Logic:**
1. Query by PhoneNumber (GSI) or EmployeeID
2. If no match → Return UNKNOWN
3. If match found:
   - No PIN provided → Return PIN_REQUIRED
   - PIN correct → Return AUTHENTICATED
   - PIN incorrect → Return INCORRECT_PIN

### Test Events

Located in `terraform/modules/lambda-function/test-events/`:

1. **test-event-phone-pin-correct.json** - Phone lookup with correct PIN
2. **test-event-phone-pin-incorrect.json** - Phone lookup with wrong PIN
3. **test-event-phone-nopin.json** - Phone lookup without PIN
4. **test-event-employee-id-pin-correct.json** - Employee ID with correct PIN
5. **test-event-no-match.json** - Unknown employee/phone

## Deployment

### 1. Deploy Infrastructure

```bash
git checkout Dynamic-Contact-Flow
cd terraform
terraform init -backend-config=backend.hcl
terraform apply
```

**New Resources Created:**
- IAM role and policy for Lambda
- DynamoDB Employee table with sample item
- Lambda function with deployment package

### 2. Import Contact Flows and Lex Bot

Same as previous branches (manual import via Console).

### 3. Test Lambda Function

**Via AWS Console:**
1. Go to Lambda Console > EmployeeBooking_DBLookup
2. Test tab > Configure test event
3. Use one of the test events from `test-events/` folder
4. Click **Test**
5. Verify return values

**Via AWS CLI:**
```bash
aws lambda invoke \
  --function-name EmployeeBooking_DBLookup \
  --payload file://terraform/modules/lambda-function/test-events/test-event-phone-pin-correct.json \
  --region us-east-1 \
  output.json

cat output.json
```

**Expected Output (Authenticated):**
```json
{
  "EmployeeType": 1,
  "EmployeeID": "101",
  "EmployeeName": "Peleke Ngaih"
}
```

### 4. Integrate with Contact Flow

**Update Contact Flow to use Lambda:**

1. Open contact flow in Amazon Connect Console
2. Add **Invoke AWS Lambda function** block
3. Select function: **EmployeeBooking_DBLookup**
4. Set function parameters:
   - `PhoneNumber`: `$.CustomerEndpoint.Address`
5. Add **Check contact attributes** block
6. Branch on `EmployeeType`:
   - `1` (AUTHENTICATED) → Transfer to Authenticated queue
   - `2` (PIN_REQUIRED) → Prompt for PIN, re-invoke Lambda
   - `0` or `3` → Transfer to Unknown queue

**Flow Logic:**
```
Entry
  │
  ├─► Get customer phone number
  ├─► Invoke Lambda (phone lookup)
  │   │
  │   ├─► EmployeeType = 1 (AUTHENTICATED)
  │   │   └─► Set queue: Authenticated
  │   │
  │   ├─► EmployeeType = 2 (PIN_REQUIRED)
  │   │   ├─► Prompt for PIN
  │   │   ├─► Invoke Lambda (with PIN)
  │   │   ├─► If correct → Authenticated queue
  │   │   └─► If incorrect → Unknown queue
  │   │
  │   └─► EmployeeType = 0 or 3
  │       └─► Set queue: Unknown
  │
  └─► Transfer to queue
```

## Variables

New variables in `terraform/variables.tf`:

```hcl
# DynamoDB Sample Employee
variable "sample_employee_id" {
  default = "101"
}

variable "sample_employee_pin" {
  default = "111"
}

variable "sample_employee_email" {
  default = "pelekengaih@gmail.com"
}

variable "sample_employee_name" {
  default = "Peleke Ngaih"
}

variable "sample_employee_phone_number" {
  default = "+18285282177"
}
```

## CI/CD Updates

GitHub Actions workflow now creates Lambda zip file:

```yaml
- name: Create Lambda Deployment Package
  run: |
    cd terraform/modules/lambda-function
    python -m zipfile -c lambda_function.zip lambda_function.py
```

**Note:** Zip file is created dynamically, not committed to repo.

## Outputs

New Terraform outputs:

| Output | Description |
|--------|-------------|
| `lambda_role_arn` | Lambda execution role ARN |
| `employee_table_name` | DynamoDB table name |
| `employee_table_arn` | DynamoDB table ARN |
| `lambda_function_name` | Lambda function name |
| `lambda_function_arn` | Lambda function ARN |

## Troubleshooting

**Lambda can't access DynamoDB:**
- Verify IAM role has DynamoDB permissions
- Check table name is "Employee"
- Verify region is us-east-1

**Employee lookup returns UNKNOWN:**
- Verify sample item exists in DynamoDB table
- Check phone number format matches exactly (include +1)
- Review Lambda CloudWatch logs

**PIN validation fails:**
- Ensure PIN is passed as string, not number
- Check EmployeePIN in DynamoDB matches
- Test with correct PIN: "111"

**Lambda deployment package missing:**
- GitHub Actions creates zip automatically
- For local: `cd terraform/modules/lambda-function && python -m zipfile -c lambda_function.zip lambda_function.py`

## Testing Scenarios

| Scenario | Input | Expected EmployeeType |
|----------|-------|----------------------|
| Known phone, correct PIN | Phone: +18285282177, PIN: 111 | 1 (AUTHENTICATED) |
| Known phone, wrong PIN | Phone: +18285282177, PIN: 999 | 3 (INCORRECT_PIN) |
| Known phone, no PIN | Phone: +18285282177 | 2 (PIN_REQUIRED) |
| Unknown phone | Phone: +15555551234 | 0 (UNKNOWN) |
| Known employee ID, correct PIN | ID: 101, PIN: 111 | 1 (AUTHENTICATED) |

## Differences from Previous Branch

| Feature | Amazon-Lex-Integration | Dynamic-Contact-Flow |
|---------|----------------------|---------------------|
| Lambda Functions | ❌ | ✅ DBLookup |
| DynamoDB | ❌ | ✅ Employee table |
| Employee Auth | ❌ | ✅ Phone/PIN validation |
| Dynamic Routing | ❌ | ✅ Based on employee type |

## Next Steps

Next branches add:
1. Lex Lambda integration (validation, fulfillment)
2. Hotel booking DynamoDB table
3. SES email confirmations
4. Serverless CCP (S3/CloudFront)

## Clean Up

```bash
terraform destroy
```

**Note:** Also manually delete:
- Lex bot
- Contact flows
- CloudWatch log groups

## Support

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Amazon Connect Docs](https://docs.aws.amazon.com/connect/)
- [AWS Lambda Python](https://docs.aws.amazon.com/lambda/latest/dg/lambda-python.html)
- [DynamoDB Developer Guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/)
