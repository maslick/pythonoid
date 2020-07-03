# test-lambda

```
sam build --use-container
sam build --use-container -m src/function1/dependencies/requirements.txt GetRecommendationsByIdFunction

sam local invoke GetRecommendationsByIdFunction

sam local start-api
curl "http://127.0.0.1:3000/getArticlesById?id=9752299010000007" | jq
curl "http://127.0.0.1:3000/getArticlesById?id=9752299010000006" | jq

sam build --use-container -m src/function1/dependencies/requirements.txt
sam deploy --stack-name test-sam-app-test --parameter-overrides 'Environment=test'
sam deploy --stack-name test-sam-app-dev --parameter-overrides 'Environment=dev'
sam deploy --guided

aws dynamodb put-item --table-name demo.ContactArticleRecommendation.dev --item file://sample.json
aws dynamodb put-item --table-name demo.ContactArticleRecommendation.test --item file://sample.json

echo "GET https://898zjlqzye.execute-api.eu-central-1.amazonaws.com/test/getArticlesById\?id\=9752299010000007" | vegeta attack -header="Content-Type: application/json" -rate=50 -duration=2s | tee results.bin | vegeta report
cat results.bin | vegeta report -type="hist[0,1ms,5ms,10ms,20ms,50ms,100ms,500ms,1000ms]"
cat results.bin | vegeta plot > plot.html
open plot.html
```


https://github.com/aws/aws-xray-sdk-python