#!/bin/bash
set -e

ENVIRONMENT=$1
STACK_NAME="test-sam-app-${ENVIRONMENT}"
: "${STACK_REGION:="eu-west-1"}"

logger () {
  RED='\033[0;31m'
  NC='\033[0m'
  echo -e ${RED}$(date -u)${NC} "\t" "$1"
}

function remove_sam_bucket() {
  logger "################################################################################################"
  logger "Remove S3 bucket for Lambda code and dependencies"
  logger "################################################################################################"
  if aws s3 ls "s3://$1" 2>&1 | grep -q 'NoSuchBucket'
  then
    logger "Bucket $1 does not exist. Exiting..."
  else
    logger "Bucket $1 exists. Removing..."
    aws s3 rb "s3://$1" --force
  fi
  echo ""
}

function remove_data_bucket() {
  logger "################################################################################################"
  logger "Remove S3 bucket with data"
  logger "################################################################################################"
  if aws s3 ls "s3://$1" 2>&1 | grep -q 'NoSuchBucket'
  then
    logger "Bucket $1 does not exist. Exiting..."
  else
    logger "Bucket $1 exists. Removing..."
    aws s3 rb "s3://$1" --force
  fi
  echo ""
}

function teardown_sam_stack() {
  logger "################################################################################################"
  logger "Teardown SAM stack"
  logger "################################################################################################"
  sam delete --stack-name $STACK_NAME --no-prompts --region $STACK_REGION
}


### Main
if [[ -z $ENVIRONMENT ]]; then
  logger "Must supply environment argument when running this script."
  logger "./teardown.sh [env]"
  exit 1
fi

remove_data_bucket "demo.contact.article.recommendation.${ENVIRONMENT}"
teardown_sam_stack
remove_sam_bucket "${STACK_NAME}-bucket"
