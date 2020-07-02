# test-lambda

```
sam build --use-container
sam build --use-container GetRecommendationsByIdFunction

sam local invoke GetRecommendationsByIdFunction

sam local start-api
curl "http://127.0.0.1:3000/getArticlesById?id=9752299010000007" | jq
curl "http://127.0.0.1:3000/getArticlesById?id=9752299010000006" | jq
```