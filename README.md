# =pythonoid=

```
# build
sam build --use-container GetRecommendationsByIdFunctionDynamo
sam build --use-container GetRecommendationsByIdFunctionS3
sam build --use-container

# test locally
sam local start-api
sam local start-api --parameter-overrides 'Environment=qa'

# deploy
sam deploy --guided
sam deploy --stack-name test-sam-app-test --parameter-overrides 'Environment=test' --no-confirm-changeset
sam deploy --stack-name test-sam-app-dev --parameter-overrides 'Environment=dev' --no-confirm-changeset
sam deploy --stack-name test-sam-app-qa --parameter-overrides 'Environment=qa' --no-confirm-changeset

# fill dynamodb with sample data
aws dynamodb put-item --table-name demo.ContactArticleRecommendation.dev --item file://dump/ddb/sample1.json
aws dynamodb put-item --table-name demo.ContactArticleRecommendation.dev --item file://dump/ddb/sample2.json

aws dynamodb put-item --table-name demo.ContactArticleRecommendation.test --item file://dump/ddb/sample1.json
aws dynamodb put-item --table-name demo.ContactArticleRecommendation.test --item file://dump/ddb/sample2.json

aws dynamodb put-item --table-name demo.ContactArticleRecommendation.qa --item file://dump/ddb/sample1.json
aws dynamodb put-item --table-name demo.ContactArticleRecommendation.qa --item file://dump/ddb/sample2.json

# put objects to s3
aws s3 cp dump/s3/9752299010000007.json s3://demo.contact.article.recommendation.$ENV
aws s3 cp dump/s3/9752299010000008.json s3://demo.contact.article.recommendation.$ENV

# test
API_ID=91bmj6l5if
REGION=eu-central-1
export ENV=dev

curl https://$API_ID.execute-api.$REGION.amazonaws.com/$ENV/getArticlesByIdDynamo?id=9752299010000007 | jq
curl https://$API_ID.execute-api.$REGION.amazonaws.com/$ENV/getArticlesByIdS3?id=9752299010000007 | jq

echo "GET https://$API_ID.execute-api.$REGION.amazonaws.com/$ENV/getArticlesByIdDynamo?id=9752299010000007" | vegeta attack -header="Accept: application/json" -rate=20 -duration=2s | tee results.bin | vegeta report
echo "GET https://$API_ID.execute-api.$REGION.amazonaws.com/$ENV/getArticlesByIdS3?id=9752299010000007" | vegeta attack -header="Content-Type: application/json" -rate=20 -duration=2s | tee results.bin | vegeta report
cat results.bin | vegeta report -type="hist[0,1ms,5ms,10ms,20ms,50ms,75ms,100ms,150ms,300ms,500ms,1000ms]"
cat results.bin | vegeta plot > plot.html
open plot.html
```
