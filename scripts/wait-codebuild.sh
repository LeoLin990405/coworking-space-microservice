#!/usr/bin/env bash
set -euo pipefail

BUILD_ID="$1"
AWS_REGION="${AWS_REGION:-us-west-2}"

while true; do
  STATUS=$(aws codebuild batch-get-builds --ids "$BUILD_ID" --region "$AWS_REGION" --query 'builds[0].buildStatus' --output text)
  echo "CodeBuild status: $STATUS"
  case "$STATUS" in
    SUCCEEDED) exit 0 ;;
    FAILED|FAULT|STOPPED|TIMED_OUT) exit 1 ;;
  esac
  sleep 15
done
