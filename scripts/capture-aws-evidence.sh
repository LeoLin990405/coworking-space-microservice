#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-us-west-2}"
PROJECT_NAME="${PROJECT_NAME:-coworking-analytics}"
ECR_REPOSITORY="${ECR_REPOSITORY:-coworking-analytics}"
CLUSTER_NAME="${CLUSTER_NAME:-coworking-cluster}"
EVIDENCE_DIR="${EVIDENCE_DIR:-submission/evidence}"

mkdir -p "$EVIDENCE_DIR"

LATEST_BUILD_ID=$(aws codebuild list-builds-for-project \
  --project-name "$PROJECT_NAME" \
  --sort-order DESCENDING \
  --region "$AWS_REGION" \
  --query 'ids[0]' \
  --output text)

aws codebuild batch-get-projects \
  --names "$PROJECT_NAME" \
  --region "$AWS_REGION" \
  > "${EVIDENCE_DIR}/codebuild-project.json"

aws codebuild batch-get-builds \
  --ids "$LATEST_BUILD_ID" \
  --region "$AWS_REGION" \
  > "${EVIDENCE_DIR}/codebuild-build.json"

aws ecr describe-repositories \
  --repository-names "$ECR_REPOSITORY" \
  --region "$AWS_REGION" \
  > "${EVIDENCE_DIR}/ecr-repository.json"

aws ecr describe-images \
  --repository-name "$ECR_REPOSITORY" \
  --region "$AWS_REGION" \
  > "${EVIDENCE_DIR}/ecr-images.json"

LOG_GROUP="/aws/containerinsights/${CLUSTER_NAME}/application"
aws logs filter-log-events \
  --log-group-name "$LOG_GROUP" \
  --region "$AWS_REGION" \
  --limit 20 \
  > "${EVIDENCE_DIR}/container-application-logs.json"

echo "Captured evidence for build ${LATEST_BUILD_ID} and log group ${LOG_GROUP}."
