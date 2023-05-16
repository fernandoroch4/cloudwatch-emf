import os
import json
import logging
from datetime import datetime

import boto3
from boto3.dynamodb.conditions import Attr, Key

logger = logging.getLogger()
logger.setLevel(int(os.getenv("LOG_LEVEL", logging.INFO)))
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.getenv("TICKET_TABLE_NAME"))

TICKET_STATUS = {"approved": "approved", "closed": "closed"}


def handler(event: dict, context) -> dict:
    logger.debug(json.dumps(event))

    status = json.loads(event["body"])["status"]

    if status not in TICKET_STATUS.values():
        return {"statusCode": 400, "body": json.dumps("Invalid status")}

    response = table.query(
        Select="COUNT",
        KeyConditionExpression=Key("ticket_id").eq(event["pathParameters"].get("id")),
        FilterExpression=Attr("ticket_status").eq(status),
    )

    if response["Count"] > 0:
        return {
            "statusCode": 400,
            "body": json.dumps(f"The item is already in the '{status}' status"),
        }

    update_expression = ""
    if status == TICKET_STATUS["approved"]:
        update_expression = "set ticket_status=:st, approved_at=:up"
    if status == TICKET_STATUS["closed"]:
        update_expression = "set ticket_status=:st, closed_at=:up"

    table.update_item(
        Key={"ticket_id": event["pathParameters"].get("id")},
        UpdateExpression=update_expression,
        ExpressionAttributeValues={
            ":st": status,
            ":up": datetime.now().isoformat(),
        },
    )
    return {"statusCode": 204}
