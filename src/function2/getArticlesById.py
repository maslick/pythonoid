import json
import boto3
import os
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
        "body": json.dumps({
            "articles": get_articles(userId),
            "timestamp": datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        }),
    }


@xray_recorder.capture('s3')
def get_articles(id):
    body = bucket.Object('{}.json'.format(id)).get()['Body'].read()
    return json.loads(body)['Articles']
