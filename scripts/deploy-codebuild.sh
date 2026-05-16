#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-west-2}"
PROJECT_NAME="${PROJECT_NAME:-coworking-analytics}"
SOURCE_BUCKET="${SOURCE_BUCKET:-leolin-coworking-codebuild-source-835207447818}"
SOURCE_KEY="${SOURCE_KEY:-coworking-source.zip}"
ARCHIVE="${SOURCE_KEY}"

aws ecr describe-repositories --repository-names "$PROJECT_NAME" --region "$AWS_REGION" >/dev/null 2>&1 \
  || aws ecr create-repository --repository-name "$PROJECT_NAME" --region "$AWS_REGION" >/dev/null

aws s3api head-bucket --bucket "$SOURCE_BUCKET" 2>/dev/null \
  || aws s3 mb "s3://${SOURCE_BUCKET}" --region "$AWS_REGION"

./scripts/package-source.sh "$ARCHIVE"
aws s3 cp "$ARCHIVE" "s3://${SOURCE_BUCKET}/${SOURCE_KEY}" --region "$AWS_REGION"

aws cloudformation deploy \
  --stack-name "${PROJECT_NAME}-codebuild-role" \
  --template-file cloudformation/codebuild-role.yml \
  --parameter-overrides ProjectName="$PROJECT_NAME" \
  --capabilities CAPABILITY_NAMED_IAM \
  --region "$AWS_REGION"

ROLE_ARN=$(aws cloudformation describe-stacks \
  --stack-name "${PROJECT_NAME}-codebuild-role" \
  --region "$AWS_REGION" \
  --query "Stacks[0].Outputs[?OutputKey=='CodeBuildRoleArn'].OutputValue" \
  --output text)

if aws codebuild batch-get-projects --names "$PROJECT_NAME" --region "$AWS_REGION" --query 'projects[0].name' --output text | grep -q "$PROJECT_NAME"; then
  aws codebuild update-project \
    --name "$PROJECT_NAME" \
    --source "type=S3,location=${SOURCE_BUCKET}/${SOURCE_KEY},buildspec=buildspec.yml" \
    --artifacts "type=NO_ARTIFACTS" \
    --environment "type=LINUX_CONTAINER,image=aws/codebuild/standard:7.0,computeType=BUILD_GENERAL1_SMALL,privilegedMode=true" \
    --service-role "$ROLE_ARN" \
    --region "$AWS_REGION" >/dev/null
else
  aws codebuild create-project \
    --name "$PROJECT_NAME" \
    --source "type=S3,location=${SOURCE_BUCKET}/${SOURCE_KEY},buildspec=buildspec.yml" \
    --artifacts "type=NO_ARTIFACTS" \
    --environment "type=LINUX_CONTAINER,image=aws/codebuild/standard:7.0,computeType=BUILD_GENERAL1_SMALL,privilegedMode=true" \
    --service-role "$ROLE_ARN" \
    --region "$AWS_REGION" >/dev/null
fi

BUILD_ID=$(aws codebuild start-build --project-name "$PROJECT_NAME" --region "$AWS_REGION" --query 'build.id' --output text)
echo "$BUILD_ID"
