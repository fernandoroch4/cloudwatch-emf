import os
import json
import logging
from datetime import datetime, timedelta
from time import mktime
from uuid import uuid4

import boto3

logger = logging.getLogger()
logger.setLevel(int(os.getenv("LOG_LEVEL", logging.INFO)))
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.getenv("TICKET_TABLE_NAME"))


def handler(event: dict, context) -> dict:
    logger.debug(json.dumps(event))

    event = json.loads(event["body"])
    _time_to_expires = datetime.now() + timedelta(days=1)
    _time_to_expires_unix = round(mktime(_time_to_expires.timetuple()))

    item = {
        "ticket_id": str(uuid4()),
        "created_at": datetime.now().isoformat(),
        "ticket_status": "opened",
        "_time_to_expires": _time_to_expires_unix,
        **event,
    }
    table.put_item(Item=item)
    del item["_time_to_expires"]
    return {"statusCode": 201, "body": json.dumps(item)}
