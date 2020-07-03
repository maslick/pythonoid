# test-lambda

```
sam build --use-container
sam build --use-container -m src/function1/dependencies/requirements.txt GetRecommendationsByIdFunction

sam local invoke GetRecommendationsByIdFunction

sam local start-api
curl "http://127.0.0.1:3000/getArticlesById?id=9752299010000007" | jq
curl "http://127.0.0.1:3000/getArticlesById?id=9752299010000006" | jq

sam build --use-container -m src/function1/dependencies/requirements.txt
sam deploy --stack-name test-sam-app --parameter-overrides 'Environment=test'
sam deploy --guided

aws dynamodb put-item --table-name demo.ContactArticleRecommendation.dev --item file://sample.json
aws dynamodb put-item --table-name demo.ContactArticleRecommendation.test --item file://sample.json
```