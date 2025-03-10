#!/usr/bin/env bash
set -euo pipefail

EVENT_PAYLOAD="${1:-}"
echo "run.sh got event: $EVENT_PAYLOAD" 1>&2

# We assume GITHUB_TOKEN was set in the Lambda's environment variables.
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "No GITHUB_TOKEN found in environment!" 1>&2
  exit 1
fi

# Adjust these to your repo details.
GITHUB_OWNER="Nazrath10R"
GITHUB_REPO="Github-Examples"
WORKFLOW_FILE_NAME="main.yml"
REF="main"

TRIGGER_URL="https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/actions/workflows/${WORKFLOW_FILE_NAME}/dispatches"

echo "Triggering GitHub Actions workflow at ${TRIGGER_URL}" 1>&2
curl -X POST \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "${TRIGGER_URL}" \
  -d "{\"ref\":\"${REF}\"}"

echo "GitHub dispatch sent." 1>&2
exit 0
