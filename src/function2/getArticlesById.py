import json
import boto3
import os
from botocore.exceptions import ClientError
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch
from datetime import datetime


patch(['boto3', 'requests'])
client = boto3.resource('s3')
bucket = client.Bucket('demo.contact.article.recommendation.{}'.format(os.environ["STAGE"]))


def lambda_handler(event, context):
    userId = event['queryStringParameters']['id']
    return {
        "statusCode": 200,
        "body": json.dumps(get_articles(userId)),
        "headers": {
            "timestamp": datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        }
    }


@xray_recorder.capture('s3')
def get_articles(id):
    try:
        body = bucket.Object('{}.json'.format(id)).get()['Body'].read().decode('utf-8')
    except ClientError as e:
        if e.response['Error']['Code'] == "NoSuchKey":
            return []
        else:
            raise
    return json.loads(body)['Articles']
