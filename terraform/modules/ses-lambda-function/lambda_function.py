#
#    MIT No Attribution
#
#    Copyright 2021 Amazon Web Services
#
#    Permission is hereby granted, free of charge, to any person obtaining a copy of this
#    software and associated documentation files (the "Software"), to deal in the Software
#    without restriction, including without limitation the rights to use, copy, modify,
#    merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
#    permit persons to whom the Software is furnished to do so.
#
#    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#    PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import boto3
import json
import logging
import os
from typing import Any, Dict
from botocore.exceptions import ClientError

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize SES client
ses = boto3.client('ses', region_name='us-east-1')

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, str]:
    """
    AWS Lambda handler for sending hotel booking confirmation emails.
    """
    logger.info(f"Incoming Event: {json.dumps(event)}")

    # Extract parameters from the event
    try:
        email_address = event['Details']['Parameters']['EmailAddress']
        booking_price = event['Details']['Parameters']['BookingPrice']
    except KeyError as e:
        logger.error(f"Missing required parameter: {e}")
        return {"lambdaResult": "Error"}

    # Get sender email from environment variable
    sender_email = os.environ.get('SENDER_EMAIL', 'noreply@example.com')

    # Construct the email message
    message = f"""
    <!DOCTYPE html>
    <html>
    <head></head>
    <body>
    <p>Hi</p>
    <p>Thank you for using our service to book a hotel.
    Your account will be charged for <b>{booking_price} dollars</b>.</p>
    <p>Thank you,<br>The Employee Booking Line</p>
    </body>
    </html>
    """

    # Set up the email parameters
    email_params = {
        "Destination": {
            "ToAddresses": [email_address]
        },
        "Message": {
            "Body": {
                "Html": {
                    "Data": message
                }
            },
            "Subject": {
                "Data": "Your Hotel Booking"
            }
        },
        "Source": sender_email
    }

    # Send the email
    try:
        response = ses.send_email(**email_params)
        logger.info(f"Email sent! Message ID: {response['MessageId']}")
        return {"lambdaResult": "Success"}
    except ClientError as e:
        logger.error(f"An error occurred: {e.response['Error']['Message']}")
        return {"lambdaResult": "Error"}
