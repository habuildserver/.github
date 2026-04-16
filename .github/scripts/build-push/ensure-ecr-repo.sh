#!/usr/bin/env bash
set -euo pipefail

# Creates the ECR repository if it doesn't exist.
# Expected env vars: REPO_NAME, SERVICE_NAME, ENVIRONMENT

aws ecr describe-repositories --repository-names "$REPO_NAME" 2>/dev/null && exit 0

echo "ECR repo '$REPO_NAME' not found — creating..."
aws ecr create-repository \
  --repository-name "$REPO_NAME" \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=AES256 \
  --tags Key=Service,Value="${SERVICE_NAME}" Key=Environment,Value="${ENVIRONMENT}"

echo "Created ECR repo: $REPO_NAME"
