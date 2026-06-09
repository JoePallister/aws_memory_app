from datetime import datetime, timezone
import boto3
import os

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])
SCALING_FACTOR = 1


def calculate_next_review_time(card):
    last_reviewed_at = card.get("last_reviewed_at")
    last_reviewed_at = int(datetime.fromisoformat(last_reviewed_at).timestamp())
    difficulty_factor = card.get("difficulty_factor")
    review_interval = card.get("review_interval")
    next_review_time = (
        last_reviewed_at + review_interval * difficulty_factor * SCALING_FACTOR
    )
    return datetime.fromtimestamp(next_review_time, tz=timezone.utc).isoformat()


def set_next_review_time(user_id, card_id, next_review_time):
    table.update_item(
        Key={
            "user_id": user_id,
            "card_id": card_id,
        },
        UpdateExpression="SET next_review_time = :nrt",
        ExpressionAttributeValues={
            ":nrt": next_review_time,
        },
    )


def lambda_handler(event, context):
    detail = event.get("detail", {})
    print(f"Flashcard created: {detail}")
    next_review_time = calculate_next_review_time(detail)
    set_next_review_time(detail["user_id"], detail["card_id"], next_review_time)
    print(f"Set next review time for card {detail['card_id']}: {next_review_time}")
    return {"statusCode": 200}
