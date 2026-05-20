#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-west-2}"
PROJECT_NAME="${PROJECT_NAME:-coworking-analytics}"
GITHUB_REPO_URL="${GITHUB_REPO_URL:-https://github.com/LeoLin990405/coworking-space-microservice.git}"
GITHUB_BRANCH="${GITHUB_BRANCH:-main}"

aws ecr describe-repositories --repository-names "$PROJECT_NAME" --region "$AWS_REGION" >/dev/null 2>&1 \
  || aws ecr create-repository --repository-name "$PROJECT_NAME" --region "$AWS_REGION" >/dev/null

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
    --source "type=GITHUB,location=${GITHUB_REPO_URL},gitCloneDepth=1,buildspec=buildspec.yml,reportBuildStatus=true" \
    --source-version "$GITHUB_BRANCH" \
    --artifacts "type=NO_ARTIFACTS" \
    --environment "type=LINUX_CONTAINER,image=aws/codebuild/standard:7.0,computeType=BUILD_GENERAL1_SMALL,privilegedMode=true" \
    --service-role "$ROLE_ARN" \
    --region "$AWS_REGION" >/dev/null
else
  aws codebuild create-project \
    --name "$PROJECT_NAME" \
    --source "type=GITHUB,location=${GITHUB_REPO_URL},gitCloneDepth=1,buildspec=buildspec.yml,reportBuildStatus=true" \
    --source-version "$GITHUB_BRANCH" \
    --artifacts "type=NO_ARTIFACTS" \
    --environment "type=LINUX_CONTAINER,image=aws/codebuild/standard:7.0,computeType=BUILD_GENERAL1_SMALL,privilegedMode=true" \
    --service-role "$ROLE_ARN" \
    --region "$AWS_REGION" >/dev/null
fi

FILTER_GROUPS="[[{\"type\":\"EVENT\",\"pattern\":\"PUSH\"},{\"type\":\"HEAD_REF\",\"pattern\":\"^refs/heads/${GITHUB_BRANCH}$\"}]]"
if aws codebuild batch-get-projects --names "$PROJECT_NAME" --region "$AWS_REGION" --query 'projects[0].webhook.url' --output text | grep -q '^https://'; then
  aws codebuild update-webhook \
    --project-name "$PROJECT_NAME" \
    --filter-groups "$FILTER_GROUPS" \
    --region "$AWS_REGION" >/dev/null
else
  aws codebuild create-webhook \
    --project-name "$PROJECT_NAME" \
    --filter-groups "$FILTER_GROUPS" \
    --region "$AWS_REGION" >/dev/null
fi

cat <<EOF
CodeBuild project '${PROJECT_NAME}' is connected to ${GITHUB_REPO_URL} on branch '${GITHUB_BRANCH}'.
Push a commit to GitHub to trigger the required automatic webhook build.
After the build completes, capture evidence showing initiator 'GitHub-Hookshot' or equivalent.
EOF
