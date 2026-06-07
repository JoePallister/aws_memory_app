import json


def lambda_handler(event, context):
    print("Received EventBridge event:")
    print(json.dumps(event, indent=2))

    detail = event.get("detail", {})
    print("Flashcard created:")
    print(detail)

    return {"statusCode": 200}
