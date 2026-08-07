#!/usr/bin/env bash
set -euo pipefail

# Validates inputs for the build-push-ecr action.
# Expected env vars: SERVICE_NAME, ENVIRONMENT, AWS_ACCOUNT_ID, DOCKERFILE_PATH, CONTEXT_PATH

if [[ ! "$SERVICE_NAME" =~ ^[a-z][a-z0-9-]+$ ]]; then
  echo "::error::Invalid service-name: must match ^[a-z][a-z0-9-]+$"
  exit 1
fi

if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
  echo "::error::Invalid environment: must be development, staging, or production"
  exit 1
fi

if [[ ! "$AWS_ACCOUNT_ID" =~ ^[0-9]{12}$ ]]; then
  echo "::error::Invalid aws-account-id: must be exactly 12 digits"
  exit 1
fi

if [ -n "${DOCKERFILE_PATH:-}" ] && [[ ! "$DOCKERFILE_PATH" =~ ^[a-zA-Z0-9_./-]+$ ]]; then
  echo "::error::Invalid dockerfile path"
  exit 1
fi

if [[ ! "${CONTEXT_PATH:-.}" =~ ^[a-zA-Z0-9_./-]+$ ]]; then
  echo "::error::Invalid context path"
  exit 1
fi

echo "All inputs valid"
