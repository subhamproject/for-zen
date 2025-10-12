#!/bin/bash
set -e

DEBUG=${DEBUG:-"0"}
if [ "${DEBUG}" = "1" ]; then
  set -x
fi

echo "Starting GitHub Actions Ephemeral Runner"

export GITHUB_PERSONAL_TOKEN=${GITHUB_PERSONAL_TOKEN:?"a token is required to start the runner"}
export GITHUB_ORG=${GITHUB_ORG:?"GitHub organization or owner is required"}
export RUNNER_GROUP=${RUNNER_GROUP:-"default"}

# Determine scope and URLs
if [ -n "${GITHUB_REPOSITORY}" ]; then
  auth_url="https://api.github.com/repos/${GITHUB_ORG}/${GITHUB_REPOSITORY}/actions/runners/registration-token"
  registration_url="https://github.com/${GITHUB_ORG}/${GITHUB_REPOSITORY}"
else
  auth_url="https://api.github.com/orgs/${GITHUB_ORG}/actions/runners/registration-token"
  registration_url="https://github.com/${GITHUB_ORG}"
fi

# Generate unique runner name using container metadata for ephemeral identification
full_id=$(curl -sSL "${ECS_CONTAINER_METADATA_URI_V4}/task" | jq --arg ARG "${CONTAINER_NAME}" -r '.Containers[] | select(.Name == $ARG) | .DockerId')
container_id=${full_id:0:12}
task_vm_id=$(uuidgen)
runner_name="${CONTAINER_NAME}-$(uuidgen)"

# Function to get ephemeral runner token
get_token() {
  payload=$(curl -sX POST -H "Authorization: token ${GITHUB_PERSONAL_TOKEN}" "${auth_url}")
  runner_token=$(echo "${payload}" | jq -r .token)
  if [ "${runner_token}" = "null" ] || [ -z "${runner_token}" ]; then
    echo "Failed to fetch runner token:"
    echo "${payload}"
    exit 1
  fi
  echo "${runner_token}"
}

# Cleanup function for graceful shutdown and deregistration
cleanup() {
  echo "Cleaning up runner registration"
  remove_token_url=""
  if [ -n "${GITHUB_REPOSITORY}" ]; then
    remove_token_url="https://api.github.com/repos/${GITHUB_ORG}/${GITHUB_REPOSITORY}/actions/runners/remove-token"
  else
    remove_token_url="https://api.github.com/orgs/${GITHUB_ORG}/actions/runners/remove-token"
  fi
  remove_token=$(curl -sX POST -H "Authorization: token ${GITHUB_PERSONAL_TOKEN}" -H "Accept: application/vnd.github.everest-preview+json" "${remove_token_url}" | jq -r '.token')
  ./config.sh remove --token "${remove_token}"
  exit 0
}

trap cleanup SIGINT SIGTERM EXIT
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM
trap 'cleanup; exit 137' SIGTERM


# Register runner as ephemeral with unique name
if [ -n "${GITHUB_REPOSITORY}" ]; then
  ./config.sh --unattended --ephemeral --name "${runner_name}" --labels "${RUNNER_LABELS}" --token "$(get_token)" --url "${registration_url}" --disableupdate
else
  ./config.sh --unattended --ephemeral --name "${runner_name}" --labels "${RUNNER_LABELS}" --token "$(get_token)" --url "${registration_url}" --runnergroup "${RUNNER_GROUP}" --disableupdate
fi

./bin/Runner.Listener warmup
./run.sh
