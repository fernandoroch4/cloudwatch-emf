import json
import logging
import os
from datetime import datetime, timedelta
from time import mktime

import boto3
from boto3.dynamodb.conditions import Attr, Key

logger = logging.getLogger()
logger.setLevel(int(os.getenv('LOG_LEVEL', logging.INFO)))
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.getenv("TICKET_TABLE_NAME"))


def handler(event: dict, context) -> dict:
    logger.debug(json.dumps(event))

    response = table.query(
        Select="COUNT",
        KeyConditionExpression=Key("ticket_id").eq(event["pathParameters"].get("id")),
        FilterExpression=Attr("ticket_status").ne('opened'),
    )

    if response["Count"] > 0:
        return {
            "statusCode": 400,
            "body": json.dumps("The item is already in progress"),
        }

    _time_to_expires = datetime.now() + timedelta(days=1)
    _time_to_expires_unix = round(mktime(_time_to_expires.timetuple()))

    table.update_item(
        Key={'ticket_id': event['pathParameters'].get('id')},
        UpdateExpression='set ticket_status=:st, deleted_at=:up, _time_to_expires=:ttl',
        ExpressionAttributeValues={
            ':st': 'deleted',
            ':up': datetime.now().isoformat(),
            ':ttl': _time_to_expires_unix,
        },
    )
    return {'statusCode': 204}
