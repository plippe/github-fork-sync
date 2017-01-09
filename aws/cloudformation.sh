#!/bin/sh

ROOT=$(realpath $(dirname $0)/..)

STACK_NAME=github-fork-sync

create () {
  S3_BUCKET=$1
  S3_KEY=$2
  GITHUB_TOKEN=$3

  # Create lambda package
  zip_file=/tmp/lambda.zip
  zip -j $zip_file $ROOT/aws/lambda.py $ROOT/github_fork_sync.py

  # Move lambda package to s3
  aws s3 mb s3://$S3_BUCKET
  aws s3 mv $zip_file s3://$S3_BUCKET/$S3_KEY

  # Create cloudformation stack
  cloudformation_parameters="ParameterKey=LambdaPackageS3Bucket,ParameterValue=$S3_BUCKET "
  cloudformation_parameters+="ParameterKey=LambdaPackageS3Key,ParameterValue=$S3_KEY "
  cloudformation_parameters+="ParameterKey=GitHubToken,ParameterValue=$GITHUB_TOKEN "

  aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://$ROOT/aws/cloudformation.yml \
  --parameters $cloudformation_parameters \
  --capabilities CAPABILITY_NAMED_IAM
}

add_sync () {
  UPSTREAM_REPO=$1
  FORK_REPO=$2
  BRANCH=${3:-master}

  arn=$(aws lambda get-function --function-name github-fork-sync-lambda | \
    grep -o 'FunctionArn": "[^"]\+' | \
    cut -d'"' -f3)

  aws events put-targets \
    --rule github-fork-sync-lambda-event \
    --targets "[{
      \"Arn\": \"$arn\",
      \"Id\": \"github-fork-sync-event-$(date +%s)\",
      \"Input\": \"{ \\\"upstream_repo\\\": \\\"$UPSTREAM_REPO\\\", \\\"fork_repo\\\": \\\"$FORK_REPO\\\", \\\"branch\\\": \\\"$BRANCH\\\" }\"
    }]"
}

delete () {
  S3_BUCKET=$1
  S3_KEY=$2

  # Delete cloudformation stack
  aws cloudformation delete-stack --stack-name $STACK_NAME
  aws s3 rm s3://$S3_BUCKET/$S3_KEY
}

if [ "$1" == "create" ] && [ $# == 4 ]; then create $2 $3 $4;
elif [ "$1" == "add-sync" ] && [ $# -ge 3 ]; then add_sync $2 $3 $4;
elif [ "$1" == "delete" ] && [ $# == 3 ]; then delete $2 $3;
else
  echo "usage: $0 {create|delete}"
  echo "  create-stack S3_BUCKET S3_KEY GITHUB_TOKEN"
  echo "  add-sync UPSTREAM_REPO FORK_REPO [BRANCH || master]"
  echo ""
  echo "  delete-stack S3_BUCKET S3_KEY"

  exit 1
fi
