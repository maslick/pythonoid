# test-lambda

```
# build
sam build --use-container -m src/function1/dependencies/requirements.txt GetRecommendationsByIdFunctionDynamo
sam build --use-container -m src/function2/dependencies/requirements.txt GetRecommendationsByIdFunctionS3

# test locally
sam local start-api

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
API_ID=mh4mnq3h3i
REGION=eu-central-1
ENV=qa
echo "GET https://$API_ID.execute-api.$REGION.amazonaws.com/$ENV/getArticlesById?id=9752299010000007" | vegeta attack -header="Content-Type: application/json" -rate=50 -duration=2s | tee results.bin | vegeta report
cat results.bin | vegeta report -type="hist[0,1ms,5ms,10ms,20ms,50ms,75ms,100ms,500ms,1000ms]"
cat results.bin | vegeta plot > plot.html
open plot.html
```
