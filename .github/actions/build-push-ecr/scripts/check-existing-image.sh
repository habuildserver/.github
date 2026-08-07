#!/usr/bin/env bash
set -euo pipefail

# Checks if an image with the given tag already exists in ECR.
# Expected env vars: REPO_NAME, GITHUB_SHA
# Writes to GITHUB_OUTPUT: exists=true|false

if aws ecr describe-images --repository-name "$REPO_NAME" \
   --image-ids imageTag="${GITHUB_SHA}" 2>/dev/null; then
  echo "exists=true" >> "$GITHUB_OUTPUT"
  echo "Image ${GITHUB_SHA} already exists in ECR — skipping build"
else
  echo "exists=false" >> "$GITHUB_OUTPUT"
fi
