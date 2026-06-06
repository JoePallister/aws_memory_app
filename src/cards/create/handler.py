import json
import boto3
import os

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def create_or_update_release(body):

    new_item = {"user_id": body["user_id"]}

    table.put_item(Item=new_item)

    return {"statusCode": 200, "body": json.dumps(new_item)}


def lambda_handler(event, context):
    method = event["requestContext"]["http"]["method"]

    if method == "POST":
        body = json.loads(event["body"])
        return create_or_update_release(body)

    return {"statusCode": 405, "body": json.dumps({"error": "method not allowed"})}
