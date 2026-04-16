#!/usr/bin/env bash
set -euo pipefail

# Sends a ClickUp notification for build success or failure.
# Expected env vars: CLICKUP_TOKEN, CLICKUP_WORKSPACE_ID, CLICKUP_CHANNEL_ID,
#                    SERVICE_NAME, ENVIRONMENT, GITHUB_REF_NAME, GITHUB_ACTOR, RUN_URL
# Arg: $1 = "success" or "failure"
# Optional env: SHORT_SHA (only for success)

[ -z "${CLICKUP_TOKEN:-}" ] && exit 0

STATUS="${1:-success}"

if [ "$STATUS" = "success" ]; then
  BODY=$(jq -n \
    --arg svc "$SERVICE_NAME" \
    --arg env "$ENVIRONMENT" \
    --arg sha "${SHORT_SHA:-}" \
    --arg branch "$GITHUB_REF_NAME" \
    --arg actor "$GITHUB_ACTOR" \
    --arg url "$RUN_URL" \
    '{type: "message", content_format: "text/md",
      content: "Built and pushed **\($svc)** (\($env))\nImage tags: `\($sha)`, `latest`\nBranch: **\($branch)**\nTriggered by: **\($actor)**\n[View run](\($url))"}')
else
  BODY=$(jq -n \
    --arg svc "$SERVICE_NAME" \
    --arg env "$ENVIRONMENT" \
    --arg branch "$GITHUB_REF_NAME" \
    --arg actor "$GITHUB_ACTOR" \
    --arg url "$RUN_URL" \
    '{type: "message", content_format: "text/md",
      content: "FAILED build **\($svc)** (\($env))\nBranch: **\($branch)**\nTriggered by: **\($actor)**\n[View run](\($url))"}')
fi

curl -sf -X POST \
  "https://api.clickup.com/api/v3/workspaces/${CLICKUP_WORKSPACE_ID}/chat/channels/${CLICKUP_CHANNEL_ID}/messages" \
  -H "Authorization: ${CLICKUP_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$BODY" || echo "::warning::ClickUp ${STATUS} notification failed"
