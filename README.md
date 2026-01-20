# Hotel Booking Call Center - Amazon Lex Enhanced

> **Branch**: `Amazon-Lex-Enhanced`
> **Purpose**: Add Lex bot fulfillment with Lambda validation and DynamoDB booking storage

Adds Lambda fulfillment for Lex BookHotel intent with validation and booking persistence. Builds on `Dynamic-Contact-Flow`.

## What's New in This Branch

**Added:**
- ✅ **Lex Lambda Function** (EmployeeBooking_LexBookHotel) - Validates and fulfills hotel bookings
- ✅ **Lex DynamoDB Table** (LexBookHotel) - Stores hotel booking records
- ✅ **Validation Logic** - City, date, and nights validation
- ✅ **Pricing Algorithm** - Location-based pricing calculation

**Inherited from previous branches:**
- 8 Contact Flows, Lex Bot (EmployeeBooking)
- Employee Lambda & DynamoDB
- Hours of Operation, Queues, Routing Profile, Agent User

**Not Yet Included:**
- SES email confirmations (next branch)
- Custom CCP (later branch)

## Repository Structure

```
.
├── Contact Flows/                      # Same 8 flows
├── Lex Bots/
├── terraform/
│   └── modules/
│       ├── lex-lambda-function/        # NEW: Lex fulfillment
│       │   ├── lambda_function.py
│       │   └── lambda_function.zip
│       ├── lex-dynamodb-table/         # NEW: Booking table
│       ├── lambda-role/
│       ├── dynamodb-table/
│       ├── lambda-function/
│       └── ...
└── .github/workflows/
```

## New Infrastructure Components

### 1. Lex Lambda Function
**Name**: EmployeeBooking_LexBookHotel
**Runtime**: Python 3.12
**Memory**: 256 MB
**Timeout**: 7 seconds
**Role**: Lambda_EmployeeBooking (shared with employee lookup)

**Purpose**: Validates hotel booking inputs and stores reservation in DynamoDB

**Handles:**
- DialogCodeHook - Validates slots during collection
- FulfillmentCodeHook - Creates booking record

**Validation:**
- **City**: Must be in supported list (10 major US cities)
- **Check-in Date**: Must not be in the past
- **Nights**: Must be between 1-30

**Supported Cities:**
- New York, Los Angeles, Chicago, Houston, Philadelphia
- Phoenix, San Antonio, San Diego, Dallas, San Jose

### 2. Lex DynamoDB Table
**Name**: LexBookHotel

**Schema:**
- **Partition Key**: TripID (String) - Random 8-character ID
- **Attributes**:
  - Location (String)
  - CheckInDate (String)
  - Nights (Number)
  - BookingPrice (Number)
  - CreatedAt (String - ISO timestamp)

### 3. Pricing Algorithm

Prices calculated based on location and nights:

```python
base_prices = {
    'new york': 200,
    'los angeles': 180,
    'chicago': 150,
    'houston': 130,
    'philadelphia': 140,
    'phoenix': 120,
    'san antonio': 110,
    'san diego': 170,
    'dallas': 130,
    'san jose': 190
}

total = base_price * nights
```

**Example**: 3 nights in New York = $600

## Lambda Function Logic

### DialogCodeHook (Validation)

```python
1. Validate Location:
   - Convert to lowercase
   - Check if in VALID_CITIES list
   - If invalid → Elicit slot with error message

2. Validate CheckInDate:
   - Parse date string
   - Check if >= today
   - If past date → Elicit slot with error

3. Validate Nights:
   - Convert to integer
   - Check if 1 <= nights <= 30
   - If invalid → Elicit slot with error

4. All valid → Calculate price, return Delegate
```

### FulfillmentCodeHook (Booking)

```python
1. Generate TripID (random 8-char string)
2. Get slot values (Location, CheckInDate, Nights)
3. Calculate price using generate_hotel_price()
4. Store in DynamoDB:
   {
     "TripID": "ABC12345",
     "Location": "New York",
     "CheckInDate": "2024-12-25",
     "Nights": 3,
     "BookingPrice": 600,
     "CreatedAt": "2024-12-20T10:30:00Z"
   }
5. Return success message with price
```

## Deployment

### 1. Deploy Infrastructure

```bash
git checkout Amazon-Lex-Enhanced
cd terraform
terraform init -backend-config=backend.hcl
terraform apply
```

**New Resources Created:**
- Lex Lambda function
- LexBookHotel DynamoDB table

### 2. Configure Lex Bot Code Hooks

**Important**: Update the Lex bot to use the new Lambda function.

1. Go to **Lex Console** > EmployeeBooking bot
2. Navigate to **BookHotel** intent
3. **Initialization code hook**:
   - Enable
   - Select Lambda: **EmployeeBooking_LexBookHotel**
4. **Fulfillment code hook**:
   - Enable
   - Select Lambda: **EmployeeBooking_LexBookHotel**
5. **Build** the bot

### 3. Test End-to-End

**Via Lex Console:**
```
You: "Book a hotel"
Bot: "What city will you be staying in?"
You: "New York"
Bot: "What date do you want to check in?"
You: "Tomorrow"
Bot: "How many nights will you be staying?"
You: "3"
Bot: "Okay, I have you down for a 3 night stay in New York
     starting tomorrow. Shall I book the reservation?"
You: "Yes"
Bot: "Thanks, I have placed your reservation. Your total is $600."
```

**Verify in DynamoDB:**
1. Go to DynamoDB Console > LexBookHotel table
2. View items - should see new booking record

## Validation Examples

### Valid Inputs
| City | Check-in | Nights | Result |
|------|----------|--------|--------|
| New York | Tomorrow | 3 | ✅ $600 |
| Los Angeles | 2024-12-25 | 5 | ✅ $900 |
| Chicago | Next Monday | 2 | ✅ $300 |

### Invalid Inputs
| Input | Error Message |
|-------|---------------|
| City: "Paris" | "I'm sorry, we don't support bookings in Paris. Please try a different city." |
| Date: "Yesterday" | "Please provide a check-in date that is today or in the future." |
| Nights: 0 | "Please provide a valid number of nights (1-30)." |
| Nights: 50 | "Please provide a valid number of nights (1-30)." |

## CI/CD Updates

GitHub Actions now creates both Lambda packages:

```yaml
- name: Create Lambda Deployment Packages
  run: |
    cd terraform/modules/lambda-function
    python -m zipfile -c lambda_function.zip lambda_function.py

    cd ../lex-lambda-function
    python -m zipfile -c lambda_function.zip lambda_function.py
```

## Variables

No new user-configurable variables in this branch. Lex DynamoDB table name is fixed as "LexBookHotel".

## Outputs

New Terraform outputs:

| Output | Description |
|--------|-------------|
| `lex_dynamodb_table_name` | LexBookHotel table name |
| `lex_dynamodb_table_arn` | LexBookHotel table ARN |
| `lex_lambda_function_name` | Lex Lambda function name |
| `lex_lambda_function_arn` | Lex Lambda ARN |

## Troubleshooting

**Validation always fails:**
- Check city name spelling (must match supported cities)
- Ensure date format is recognized by Lex (use "tomorrow", "YYYY-MM-DD", etc.)
- Verify nights is a number, not text

**Booking not saved to DynamoDB:**
- Verify Lambda has DynamoDB PutItem permission
- Check Lambda CloudWatch logs for errors
- Ensure table name is "LexBookHotel"

**Lambda timeout:**
- Default timeout is 7 seconds (should be sufficient)
- Check for DynamoDB throttling in CloudWatch
- Verify table is in same region (us-east-1)

**Code hook not invoked:**
- Ensure bot is built after adding Lambda
- Verify both initialization and fulfillment hooks are enabled
- Check Lex has permission to invoke Lambda

## Testing

**Test DialogCodeHook (Invalid City):**
```json
{
  "invocationSource": "DialogCodeHook",
  "sessionState": {
    "intent": {
      "name": "BookHotel",
      "slots": {
        "Location": {"value": {"interpretedValue": "Paris"}},
        "CheckInDate": null,
        "Nights": null
      }
    }
  }
}
```

**Expected**: Elicit Location slot with error message

**Test FulfillmentCodeHook (Valid Booking):**
```json
{
  "invocationSource": "FulfillmentCodeHook",
  "sessionState": {
    "intent": {
      "name": "BookHotel",
      "slots": {
        "Location": {"value": {"interpretedValue": "New York"}},
        "CheckInDate": {"value": {"interpretedValue": "2024-12-25"}},
        "Nights": {"value": {"interpretedValue": "3"}}
      }
    }
  }
}
```

**Expected**: Close with success message and price

## Differences from Previous Branch

| Feature | Dynamic-Contact-Flow | Amazon-Lex-Enhanced |
|---------|---------------------|---------------------|
| Employee Lambda/DDB | ✅ | ✅ (same) |
| Lex Validation | ❌ | ✅ Lambda hooks |
| Hotel Booking Storage | ❌ | ✅ LexBookHotel table |
| Pricing | ❌ | ✅ Location-based |

## Next Steps

Next branches add:
1. SES email confirmations - Send booking details via email
2. Serverless CCP - Custom CCP on S3/CloudFront

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
- [Amazon Lex Code Hooks](https://docs.aws.amazon.com/lexv2/latest/dg/lambda.html)
- [AWS Lambda Python](https://docs.aws.amazon.com/lambda/latest/dg/lambda-python.html)
- [DynamoDB Developer Guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/)
