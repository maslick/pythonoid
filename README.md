# =pythonoid=

```
# build and deploy
ENV="qa"
./deploy.sh $ENV 

# test
URL=$(aws cloudformation describe-stacks --stack-name "test-sam-app-${ENV}" --query "Stacks[0].Outputs[?OutputKey=='RecommendationsApi'].OutputValue" --output text)

USER_ID="9752299010000008"
curl -s "$URL/getArticlesByIdDynamo?id=$USER_ID" | jq
curl -s "$URL/getArticlesByIdS3?id=$USER_ID" | jq

# load testing
echo "GET $URL/getArticlesByIdDynamo?id=$USER_ID" | vegeta attack -header="Accept: application/json" -rate=20 -duration=2s | tee results.bin | vegeta report
echo "GET $URL/getArticlesByIdS3?id=$USER_ID" | vegeta attack -header="Content-Type: application/json" -rate=20 -duration=2s | tee results.bin | vegeta report
cat results.bin | vegeta report -type="hist[0,1ms,5ms,10ms,20ms,50ms,75ms,100ms,150ms,300ms,500ms,1000ms]"
cat results.bin | vegeta plot > plot.html
open plot.html
```
