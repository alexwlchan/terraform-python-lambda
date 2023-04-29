import json
import os

import boto3


def send_message_to_queue(message):
    sqs = boto3.client("sqs")
    queue_url = os.environ["QUEUE_URL"]

    sqs.send_message(QueueUrl=queue_url, MessageBody=message)


def process_message_from_sns(message: dict):
    print(f"Received message: {message!r}")
    send_message_to_queue(message=f"Successfully processed message {message!r}")


def main(event, context):
    for record in event["Records"]:
        message = json.loads(record["Sns"]["Message"])
        process_message_from_sns(message)


if __name__ == "__main__":
    process_message_from_sns(message="hello world")
