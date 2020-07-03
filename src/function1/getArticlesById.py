import json
import boto3
import os
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch

libraries = (['boto3', 'requests'])
patch(libraries)

client = boto3.resource('dynamodb')
table = client.Table('demo.ContactArticleRecommendation.{}'.format(os.environ["STAGE"]))


def lambda_handler(event, context):
    userId = event['queryStringParameters']['id']

    xray_recorder.begin_segment()
    subsegment = xray_recorder.begin_subsegment('ddb_call')
    articles = get_articles(userId)
    subsegment.put_metadata('ddb', dict, 'namespace')
    subsegment.put_annotation('ddb', 'value')
    xray_recorder.end_subsegment()

    return {
        "statusCode": 200,
        "body": json.dumps({
            "articles": articles
        }),
    }


def get_articles(id):
    resp = table.get_item(Key={"ContactId": id})
    if 'Item' in resp:
        return resp['Item']['Articles']
    return []

