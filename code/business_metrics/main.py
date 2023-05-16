import json
import logging
import os
import time

from deepdiff import DeepDiff

logger = logging.getLogger()
logger.setLevel(int(os.getenv('LOG_LEVEL', logging.INFO)))


def put_metric(name, value, unit) -> None:
    # fmt: off
    print(json.dumps({
        'ServiceName': 'BusinessMetrics',
        '_aws': {
            'Timestamp': int(round(time.time() * 1000)),
            'CloudWatchMetrics': [
                {
                    'Dimensions': [['ServiceName']],
                    'Metrics': [{'Name': name, 'Unit': unit, 'StorageResolution': 1}],
                    'Namespace': 'DemoCloudWatchEmf'
                }
            ]
        },
        f'{name}': value
    }))


def _debug(event, context) -> None:
    logger.debug('Input event: %s', json.dumps(event))
    logger.debug('Lambda function ARN: %s', context.invoked_function_arn)
    logger.debug('CloudWatch log stream name: %s', context.log_stream_name)
    logger.debug('CloudWatch log group name: %s', context.log_group_name)
    logger.debug('Lambda Request ID: %s', context.aws_request_id)
    logger.debug('Lambda function memory limits in MB: %s', context.memory_limit_in_mb)
    logger.debug(
        'Lambda time remaining in MS: %s', context.get_remaining_time_in_millis()
    )


def handler(event: dict, context):
    _debug(event, context)

    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            put_metric('ticket.opened', 1, 'Count')

        if record['eventName'] == 'MODIFY':
            new_image = record['dynamodb']['NewImage']
            old_image = record['dynamodb']['OldImage']

            diff = DeepDiff(old_image, new_image)
            dictionary_item_added = diff.to_dict().get('dictionary_item_added', [])

            logger.debug('diff: %s', diff)
            logger.debug('dictionary_item_added: %s', dictionary_item_added)

            if len(dictionary_item_added) == 0:
                continue
            change_behaviour = diff.to_dict()['dictionary_item_added'][0]
            logger.debug('change_behaviour: %s', change_behaviour)

            if change_behaviour == "root['approved_at']":
                put_metric('ticket.approved', 1, 'Count')
            if change_behaviour == "root['closed_at']":
                put_metric('ticket.closed', 1, 'Count')
            if change_behaviour == "root['deleted_at']":
                put_metric('ticket.deleted', 1, 'Count')

    return {'statusCode': 200}
