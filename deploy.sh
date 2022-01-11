#!/bin/bash
set -e

ENVIRONMENT=$1
STACK_NAME="test-sam-app-${ENVIRONMENT}"
S3BUCKET="$STACK_NAME-bucket"

logger () {
  RED='\033[0;31m'
  NC='\033[0m'
  echo -e ${RED}$(date -u)${NC} "\t" "$1"
}

function create_sam_bucket() {
  logger "################################################################################################"
  logger "Create S3 bucket for Lambda code and dependencies"
  logger "################################################################################################"
  if aws s3 ls "s3://$1" 2>&1 | grep -q 'NoSuchBucket'
  then
    logger "Bucket $1 does not exist. Creating..."
    aws s3 mb "s3://$1"
  else
    logger "Bucket $1 already exists. Skipping..."
  fi
  echo ""
}

function install_packages() {
  logger "################################################################################################"
  logger "Download dependencies and Generate CFN template"
  logger "################################################################################################"
  sam build #--use-container
  echo ""
}

function deploy_app() {
  logger "################################################################################################"
  logger "Deploy app to $ENVIRONMENT environment"
  logger "################################################################################################"
  sam deploy --stack-name $STACK_NAME \
      --parameter-overrides "Environment=${ENVIRONMENT} EndpointType=PRIVATE" \
      --s3-bucket $S3BUCKET \
      --no-confirm-changeset \
      --no-fail-on-empty-changeset \
      --capabilities CAPABILITY_IAM
  logger "Done."
  echo ""
}

function put_sample_data_dynamodb() {
  logger "################################################################################################"
  logger "Put sample data in DynamoDB table"
  logger "################################################################################################"
  TABLE_NAME="demo.ContactArticleRecommendation.${ENVIRONMENT}"
  aws dynamodb put-item --table-name $TABLE_NAME --item file://dump/ddb/sample1.json
  aws dynamodb put-item --table-name $TABLE_NAME --item file://dump/ddb/sample2.json
  logger "Done."
  echo ""
}

function put_sample_data_s3() {
  logger "################################################################################################"
  logger "Put sample data in S3 bucket"
  logger "################################################################################################"
  BUCKET_NAME="s3://demo.contact.article.recommendation.${ENVIRONMENT}"
  aws s3 cp dump/s3/9752299010000007.json $BUCKET_NAME
  aws s3 cp dump/s3/9752299010000008.json $BUCKET_NAME
  logger "Done."
  echo ""
}


### Main
if [[ -z $ENVIRONMENT ]]; then
  logger "Must supply environment argument when running this script."
  logger "./deploy.sh [env]"
  exit 1
fi

create_sam_bucket $S3BUCKET
install_packages
deploy_app
put_sample_data_dynamodb
put_sample_data_s3
