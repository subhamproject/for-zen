#!/bin/bash
set -e

# Required environment variables:
# - RUNNER_SCOPE   ("org" or "repo")
# - GITHUB_OWNER   (organization or user name)
# - GITHUB_REPO    (if scope is "repo"; unset for org-runner)
# - GITHUB_PAT     (GitHub Personal Access Token with runner registration scope)
# - RUNNER_LABELS  (labels for this runner, optional)

if [ -z "$RUNNER_SCOPE" ] || [ -z "$GITHUB_OWNER" ] || [ -z "$GITHUB_PAT" ]; then
  echo "Missing required environment variables."
  exit 1
fi

if [ "$RUNNER_SCOPE" = "repo" ] && [ -z "$GITHUB_REPO" ]; then
  echo "For repo scope, GITHUB_REPO must be set."
  exit 1
fi

# Compose registration URL
if [ "$RUNNER_SCOPE" = "org" ]; then
  REG_URL="https://api.github.com/orgs/${GITHUB_OWNER}/actions/runners/registration-token"
  GITHUB_URL="https://github.com/${GITHUB_OWNER}"
else
  REG_URL="https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/actions/runners/registration-token"
  GITHUB_URL="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}"
fi

# Retrieve short-lived runner registration token using the PAT
TOKEN_JSON=$(curl -s -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_PAT}" \
  "${REG_URL}")

RUNNER_TOKEN=$(echo "${TOKEN_JSON}" | grep -oP '"token"\s*:\s*"\K[^"]+')

if [ -z "$RUNNER_TOKEN" ]; then
  echo "Could not get runner token from GitHub API!"
  echo "$TOKEN_JSON"
  exit 2
fi

cd /actions-runner

# Register and configure the runner as ephemeral
./config.sh --url "${GITHUB_URL}" \
  --token "${RUNNER_TOKEN}" \
  --labels "${RUNNER_LABELS:-fargate,ephemeral}" \
  --ephemeral \
  --unattended

cleanup() {
  ./config.sh remove --unattended --token "${RUNNER_TOKEN}"
}
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Start the runner
./run.sh

cleanup
