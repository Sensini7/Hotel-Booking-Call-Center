# Lambda Function Test Events

This directory contains test events for the `EmployeeBooking_DBLookup` Lambda function.

## Test Scenarios

### 1. Unknown Phone Number (`1-unknown-phone-number.json`)
Tests the scenario where a caller's phone number is not found in the DynamoDB table.

**Expected Result:**
```json
{
  "EmployeeID": null,
  "EmployeeName": "Unknown",
  "EmailAddress": "Unknown",
  "EmployeePIN": null,
  "EmployeeType": 0
}
```
- `EmployeeType: 0` = UNKNOWN

### 2. Existing Employee Phone (`2-existing-employee-phone.json`)
Tests the scenario where a caller's phone number exists in the DynamoDB table but no PIN is provided.

**Expected Result:**
```json
{
  "EmployeeID": "101",
  "EmployeeName": "peleke",
  "EmailAddress": "peleke@gmail.com",
  "EmployeePIN": null,
  "EmployeeType": 2
}
```
- `EmployeeType: 2` = PIN_REQUIRED

### 3. Existing Employee with Correct PIN (`3-existing-employee-with-pin.json`)
Tests the scenario where a caller's phone number exists and they provide the correct PIN.

**Expected Result:**
```json
{
  "EmployeeID": "101",
  "EmployeeName": "peleke",
  "EmailAddress": "peleke@gmail.com",
  "EmployeePIN": null,
  "EmployeeType": 1
}
```
- `EmployeeType: 1` = AUTHENTICATED

### 4. Employee ID with Correct PIN (`4-employeeid-with-correct-pin.json`)
Tests the scenario where an employee provides their ID and correct PIN.

**Expected Result:**
```json
{
  "EmployeeID": "101",
  "EmployeeName": "peleke",
  "EmailAddress": "peleke@gmail.com",
  "EmployeePIN": null,
  "EmployeeType": 1
}
```
- `EmployeeType: 1` = AUTHENTICATED

### 5. Employee ID with Wrong PIN (`5-employeeid-with-wrong-pin.json`)
Tests the scenario where an employee provides their ID but an incorrect PIN.

**Expected Result:**
```json
{
  "EmployeeID": "101",
  "EmployeeName": "peleke",
  "EmailAddress": "peleke@gmail.com",
  "EmployeePIN": null,
  "EmployeeType": 3
}
```
- `EmployeeType: 3` = INCORRECT_PIN

## Employee Type Values

- `0` = UNKNOWN - Employee not found
- `1` = AUTHENTICATED - Employee found and PIN verified
- `2` = PIN_REQUIRED - Employee found but PIN not provided
- `3` = INCORRECT_PIN - Employee found but PIN is incorrect

## How to Use These Test Events

### Option 1: AWS Console
1. Navigate to the Lambda function in AWS Console
2. Click on the "Test" tab
3. Click "Create new event"
4. Paste the content from one of the JSON files
5. Give it a name (e.g., "UnknownPhoneNumber")
6. Click "Test" to execute

### Option 2: AWS CLI
```bash
aws lambda invoke \
  --function-name EmployeeBooking_DBLookup \
  --payload file://test-events/1-unknown-phone-number.json \
  response.json

cat response.json
```

### Option 3: Local Testing with Python
```python
import json
from lambda_function import lambda_handler

# Load test event
with open('test-events/1-unknown-phone-number.json', 'r') as f:
    event = json.load(f)

# Execute function
result = lambda_handler(event, None)
print(json.dumps(result, indent=2))
```

## Notes
- Test event 2 uses the phone number from the sample employee data: `+18285282177`
- Test event 3 uses the same phone number with the correct PIN: `111`
- Test events 4 and 5 use the Employee ID directly instead of phone number lookup
- Make sure the DynamoDB table has the sample employee data before running these tests
