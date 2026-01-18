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
import random
import string
from datetime import datetime

dynamodb = boto3.client('dynamodb')
logger = logging.getLogger()
logger.setLevel(logging.INFO)

TABLE_NAME = 'LexBookHotel'
VALID_CITIES = {'new york', 'los angeles', 'chicago', 'houston', 'philadelphia', 'phoenix', 'san antonio', 'san diego', 'dallas', 'san jose'}

def lambda_handler(event, context):
    logger.info(f"Event payload: {json.dumps(event)}")
    try:
        return dispatch(event)
    except Exception as err:
        logger.error(f"Error: {err}")
        return close(
            event['sessionState'],
            'Failed',
            event['sessionState']['intent']['name'],
            {'contentType': 'PlainText', 'content': "I'm sorry, there was an error processing your request."}
        )

def dispatch(intent_request):
    intent_name = intent_request['sessionState']['intent']['name']
    logger.info(f"dispatch userId={intent_request['sessionId']}, intentName={intent_name}")

    if intent_name == 'BookHotel':
        return book_hotel(intent_request)

    raise Exception(f"Intent with name {intent_name} not supported")

def book_hotel(intent_request):
    session_attributes = intent_request['sessionState'].get('sessionAttributes', {})
    slots = intent_request['sessionState']['intent']['slots']

    location = get_slot_value(slots, 'Location')
    check_in_date = get_slot_value(slots, 'CheckInDate')
    nights = get_slot_value(slots, 'Nights')

    if intent_request['invocationSource'] == 'DialogCodeHook':
        validation_result = validate_hotel(location, check_in_date, nights)
        if not validation_result['isValid']:
            return elicit_slot(
                intent_request['sessionState'],
                intent_request['sessionState']['intent']['name'],
                slots,
                validation_result['violatedSlot'],
                validation_result['message']
            )

        if location and check_in_date and nights:
            price = generate_hotel_price(location, int(nights))
            session_attributes['currentReservationPrice'] = str(price)

        return delegate(intent_request['sessionState'])

    # Booking finalization
    if location and check_in_date and nights:
        reservation = {
            'ReservationType': 'Hotel',
            'Location': location,
            'CheckInDate': check_in_date,
            'Nights': nights
        }

        price = session_attributes.get('currentReservationPrice', generate_hotel_price(location, int(nights)))
        store_hotel_booking(reservation, price, session_attributes.get('CC_EmployeeID'))

        return close(
            intent_request['sessionState'],
            'Fulfilled',
            intent_request['sessionState']['intent']['name'],
            {'contentType': 'PlainText', 'content': f'Thanks, I have placed your reservation for {nights} nights in {location} starting {check_in_date}. The total price is ${price}.'}
        )
    else:
        return delegate(intent_request['sessionState'])

def get_slot_value(slots, slot_name):
    slot = slots.get(slot_name)
    if slot and 'value' in slot and 'interpretedValue' in slot['value']:
        return slot['value']['interpretedValue']
    return None

def validate_hotel(location, check_in_date, nights):
    if location and location.lower() not in VALID_CITIES:
        return build_validation_result(False, 'Location', f"We currently do not support {location} as a valid destination. Can you try a different city?")

    if check_in_date:
        try:
            parsed_date = datetime.strptime(check_in_date, '%Y-%m-%d')
            if parsed_date < datetime.now():
                return build_validation_result(False, 'CheckInDate', 'Reservations must be scheduled at least one day in advance. Can you try a different date?')
        except ValueError:
            return build_validation_result(False, 'CheckInDate', 'I did not understand your check-in date. When would you like to check in?')

    if nights:
        try:
            nights_int = int(nights)
            if nights_int < 1 or nights_int > 30:
                return build_validation_result(False, 'Nights', 'You can make reservations for 1 to 30 nights. How many nights would you like to stay?')
        except ValueError:
            return build_validation_result(False, 'Nights', 'I did not understand the number of nights. How many nights would you like to stay?')

    return {'isValid': True}

def store_hotel_booking(reservation, price, employee_id):
    trip_id = ''.join(random.choices(string.ascii_lowercase + string.digits, k=16))

    item = {
        'TripID': {'S': trip_id},
        'ReservationType': {'S': reservation['ReservationType']},
        'Location': {'S': reservation['Location']},
        'CheckInDate': {'S': reservation['CheckInDate']},
        'Nights': {'S': reservation['Nights']},
        'Price': {'S': price},
        'EmployeeID': {'S': employee_id or 'N/A'}
    }

    try:
        dynamodb.put_item(TableName=TABLE_NAME, Item=item)
        logger.info("Hotel booking stored successfully")
    except Exception as err:
        logger.error(f"Error storing hotel booking: {err}")
        raise

def generate_hotel_price(location, nights):
    base_price = 100
    location_factor = sum(ord(char.lower()) - 96 for char in location if char.isalpha())
    return (base_price + location_factor) * nights

def build_validation_result(is_valid, violated_slot, message_content):
    return {
        'isValid': is_valid,
        'violatedSlot': violated_slot,
        'message': {'contentType': 'PlainText', 'content': message_content}
    }

def elicit_slot(session_state, intent_name, slots, slot_to_elicit, message):
    return {
        'sessionState': {
            'dialogAction': {
                'type': 'ElicitSlot',
                'slotToElicit': slot_to_elicit
            },
            'intent': {
                'name': intent_name,
                'slots': slots
            },
            'sessionAttributes': session_state.get('sessionAttributes', {})
        },
        'messages': [message]
    }

def delegate(session_state):
    return {
        'sessionState': {
            'dialogAction': {
                'type': 'Delegate'
            },
            'intent': session_state['intent'],
            'sessionAttributes': session_state.get('sessionAttributes', {})
        }
    }

def close(session_state, fulfillment_state, intent_name, message):
    return {
        'sessionState': {
            'dialogAction': {
                'type': 'Close'
            },
            'intent': {
                'name': intent_name,
                'state': fulfillment_state
            },
            'sessionAttributes': session_state.get('sessionAttributes', {})
        },
        'messages': [message]
    }
