import json
import boto3
import os
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch


patch(['boto3', 'requests'])
client = boto3.resource('dynamodb')
table = client.Table('demo.ContactArticleRecommendation.{}'.format(os.environ["STAGE"]))


def lambda_handler(event, context):
    userId = event['queryStringParameters']['id']
    return {
        "statusCode": 200,
        "body": json.dumps({
            "articles": get_articles(userId)
        }),
    }


@xray_recorder.capture('ddb')
def get_articles(id):
    resp = table.get_item(Key={"ContactId": id})
    if 'Item' in resp:
        return resp['Item']['Articles']
    return []

