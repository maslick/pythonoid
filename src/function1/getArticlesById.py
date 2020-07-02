import json
import boto3

client = boto3.resource('dynamodb', region_name="eu-west-1")
table = client.Table('demo.ContactArticleRecommendation')


def lambda_handler(event, context):
    userId = event['queryStringParameters']['id']
    return {
        "statusCode": 200,
        "body": json.dumps({
            "articles": get_articles(userId)
        }),
    }


def get_articles(id):
    resp = table.get_item(Key={"ContactId": id})
    if 'Item' in resp:
        return resp['Item']['Articles']
    return []

