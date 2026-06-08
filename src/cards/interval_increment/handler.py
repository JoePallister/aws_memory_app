import json
import os
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def update_card_interval(card_id, user_id, interval_increment):
    response = table.get_item(Key={"user_id": user_id, "card_id": card_id})
    if "Item" not in response:
        raise ValueError("Card not found")

    card = response["Item"]

    new_interval = card["review_interval"] + interval_increment
    if new_interval < 1:
        new_interval = 1

    table.update_item(
        Key={"user_id": user_id, "card_id": card_id},
        UpdateExpression="SET review_interval = :new_interval",
        ExpressionAttributeValues={":new_interval": new_interval},
    )


def lambda_handler(event, context):
    body = json.loads(event["body"])
    card_id = event["pathParameters"]["card_id"]
    user_id = body.get("user_id")
    interval_increment = body.get("interval_increment")
    try:
        print(
            f"Updating card {card_id} for user {user_id} with interval increment {interval_increment}"
        )
        update_card_interval(card_id, user_id, interval_increment)
        return {
            "statusCode": 200,
            "body": json.dumps(
                {"card_id": card_id, "interval_increment": interval_increment}
            ),
        }
    except ValueError as e:
        return {"statusCode": 400, "body": json.dumps({"error": str(e)})}
