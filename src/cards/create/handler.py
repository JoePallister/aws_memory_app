import json
import uuid
import boto3
import os
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def validate_card(data):
    if "user_id" not in data:
        raise ValueError("Missing user_id")
    if "card_front" not in data:
        raise ValueError("Missing card_front")
    if "card_back" not in data:
        raise ValueError("Missing card_back")


def post_card(body):
    validate_card(body)
    new_item = {
        "user_id": body["user_id"],
        "card_id": str(uuid.uuid4()),
        "card_front": body["card_front"],
        "card_back": body["card_back"],
    }
    table.put_item(Item=new_item)
    return {"statusCode": 200, "body": json.dumps(new_item)}


def get_cards(user_id):
    response = table.query(KeyConditionExpression=Key("user_id").eq(user_id))
    cards = response["Items"]
    return cards


def lambda_handler(event, context):
    method = event["requestContext"]["http"]["method"]
    if method == "POST":
        body = json.loads(event["body"])
        try:
            return post_card(body)
        except ValueError as e:
            return {"statusCode": 400, "body": json.dumps({"error": str(e)})}
    if method == "GET":
        user_id = event["pathParameters"]["user_id"]
        cards = get_cards(user_id)
        return {"statusCode": 200, "body": json.dumps(cards)}
    return {"statusCode": 405, "body": json.dumps({"error": "method not allowed"})}
