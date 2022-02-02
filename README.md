# =pythonoid=
AWS API Gateway, Lambda, DynamoDB, S3, SAM showcase

## Build and deploy
```
ENV="qa"
./deploy.sh $ENV
```

## Public API GW
```
URL=$(aws cloudformation describe-stacks --stack-name "test-sam-app-${ENV}" --query "Stacks[0].Outputs[?OutputKey=='RecommendationsApi'].OutputValue" --output text)
USER_ID="9752299010000008"

curl -s "$URL/getArticlesByIdDynamo?id=$USER_ID" | jq
curl -s "$URL/getArticlesByIdS3?id=$USER_ID" | jq
```

## Private API GW
```
VPC_ENDPOINT="vpce-0b33950a675d1da90-5lxxxxx"
API_ID="dr1yyyyy"
REGION="eu-west-1"
USER_ID="9752299010000008"
STAGE="qa"

API_ID="dr1yyyyy"
URL1="https://$VPC_ENDPOINT.execute-api.$REGION.vpce.amazonaws.com/$STAGE/getArticlesByIdDynamo?id=$USER_ID"
URL2="https://$VPC_ENDPOINT.execute-api.$REGION.vpce.amazonaws.com/$STAGE/getArticlesByIdS3?id=$USER_ID"

curl -s --header "x-apigw-api-id: $API_ID" $URL1 | jq
curl -s --header "x-apigw-api-id: $API_ID" $URL2 | jq

curl -i --header "x-apigw-api-id: $API_ID" $URL1
curl -i --header "x-apigw-api-id: $API_ID" $URL2

curl -s --header "Cache-Control: max-age=0" --header "x-apigw-api-id: $API_ID" $URL1 | jq
curl -s --header "Cache-Control: max-age=0" --header "x-apigw-api-id: $API_ID" $URL2 | jq

```

## Load testing
```
echo "GET $URL/getArticlesByIdDynamo?id=$USER_ID" | vegeta attack -header="Accept: application/json" -rate=20 -duration=2s | tee results.bin | vegeta report
echo "GET $URL/getArticlesByIdS3?id=$USER_ID" | vegeta attack -header="Content-Type: application/json" -rate=20 -duration=2s | tee results.bin | vegeta report
cat results.bin | vegeta report -type="hist[0,1ms,5ms,10ms,20ms,50ms,75ms,100ms,150ms,300ms,500ms,1000ms]"
cat results.bin | vegeta plot > plot.html
open plot.html
```
