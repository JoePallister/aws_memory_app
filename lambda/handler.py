import json
import boto3
import os

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def get_release(service):
    response = table.get_item(Key={"service": service})

    item = response.get("Item")

    if not item:
        return {"statusCode": 404, "body": json.dumps({"error": "not found"})}

    return {"statusCode": 200, "body": json.dumps(item)}


def create_or_update_release(service, body):

    error = validate_body(body)
    if error:
        return {"statusCode": 400, "body": json.dumps({"error": error})}

    existing = table.get_item(Key={"service": service}).get("Item")

    history = existing.get("history", []) if existing else []

    if existing:
        old_version = existing.get("current_version")
        if old_version and old_version != body["version"]:
            history.append(old_version)

    new_item = {
        "service": service,
        "current_version": body["version"],
        "enabled": body["enabled"],
        "history": history[-10:],  # keep last 10 versions
    }

    table.put_item(Item=new_item)

    return {"statusCode": 200, "body": json.dumps(new_item)}


def validate_body(body):
    if "version" not in body:
        return "missing version"

    if "enabled" not in body:
        return "missing enabled"

    if not isinstance(body["version"], str):
        return "version must be string"

    if not isinstance(body["enabled"], bool):
        return "enabled must be boolean"

    return None


def rollback_release(service):

    item = table.get_item(Key={"service": service}).get("Item")

    if not item:
        return {"statusCode": 404, "body": json.dumps({"error": "service not found"})}

    history = item.get("history", [])

    if not history:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "no previous version to rollback to"}),
        }

    previous_version = history.pop()

    new_item = {
        "service": service,
        "current_version": previous_version,
        "enabled": item.get("enabled", True),
        "history": history,
    }

    table.put_item(Item=new_item)

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "rolled back",
                "service": service,
                "current_version": previous_version,
            }
        ),
    }


def lambda_handler(event, context):

    service = event["pathParameters"]["service"]
    method = event["requestContext"]["http"]["method"]
    path = event["rawPath"]

    if method == "GET":
        return get_release(service)

    if method == "POST" and path.endswith("/rollback"):
        return rollback_release(service)

    if method == "POST":
        body = json.loads(event["body"])
        return create_or_update_release(service, body)

    return {"statusCode": 405, "body": json.dumps({"error": "method not allowed"})}
