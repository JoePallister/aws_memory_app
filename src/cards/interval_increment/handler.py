import json
import os
import boto3
from decimal import Decimal
from datetime import datetime, timezone

events = boto3.client("events")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def decimal_default(obj):
    if isinstance(obj, Decimal):
        return int(obj) if obj % 1 == 0 else float(obj)
    raise TypeError


def update_card_interval(card_id, user_id, interval_increment):
    response = table.get_item(Key={"user_id": user_id, "card_id": card_id})
    if "Item" not in response:
        raise ValueError("Card not found")

    card = response["Item"]

    new_interval = card["review_interval"] + interval_increment
    if new_interval < 1:
        new_interval = 1

    now_iso = datetime.now(timezone.utc).isoformat()

    updated = table.update_item(
        Key={"user_id": user_id, "card_id": card_id},
        UpdateExpression="SET review_interval = :new_interval, last_reviewed_at = :lra",
        ExpressionAttributeValues={":new_interval": new_interval, ":lra": now_iso},
        ReturnValues="ALL_NEW",
    )

    return updated.get("Attributes", card)


def push_event(card):
    resp = events.put_events(
        Entries=[
            {
                "Source": "anki.cards",
                "DetailType": "FlashcardReviewed",
                "Detail": json.dumps(
                    {
                        "user_id": card["user_id"],
                        "card_id": card["card_id"],
                        "last_reviewed_at": card.get("last_reviewed_at"),
                        "difficulty_factor": card.get("difficulty_factor"),
                        "review_interval": card.get("review_interval"),
                    },
                    default=decimal_default,
                ),
            }
        ]
    )

    print(f"put_events response: {resp}")


def lambda_handler(event, context):
    body = json.loads(event["body"])
    card_id = event["pathParameters"]["card_id"]
    user_id = body.get("user_id")
    interval_increment = body.get("interval_increment")
    try:
        print(
            f"Updating card {card_id} for user {user_id} with interval increment {interval_increment}"
        )
        updated_card = update_card_interval(card_id, user_id, interval_increment)
        push_event(updated_card)
        return {
            "statusCode": 200,
            "body": json.dumps(updated_card, default=decimal_default),
        }
    except ValueError as e:
        return {"statusCode": 400, "body": json.dumps({"error": str(e)})}
