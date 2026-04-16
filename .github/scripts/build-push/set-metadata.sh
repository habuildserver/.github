#!/usr/bin/env bash
set -euo pipefail

# Computes image metadata and writes to GITHUB_OUTPUT.
# Expected env vars: AWS_ACCOUNT_ID, AWS_REGION, SERVICE_NAME, ENVIRONMENT,
#                    INPUT_DOCKERFILE, GITHUB_SHA

ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SERVICE_NAME}-${ENVIRONMENT}"
DOCKERFILE="${INPUT_DOCKERFILE:-build/Dockerfile-${ENVIRONMENT}}"

echo "ecr-repo=${ECR_REPO}" >> "$GITHUB_OUTPUT"
echo "image-tag=${GITHUB_SHA}" >> "$GITHUB_OUTPUT"
echo "short-sha=${GITHUB_SHA:0:7}" >> "$GITHUB_OUTPUT"
echo "image-uri=${ECR_REPO}:${GITHUB_SHA}" >> "$GITHUB_OUTPUT"
echo "dockerfile=${DOCKERFILE}" >> "$GITHUB_OUTPUT"

echo "ECR repo: ${ECR_REPO}"
echo "Tag: ${GITHUB_SHA:0:7} (${GITHUB_SHA})"
echo "Dockerfile: ${DOCKERFILE}"
