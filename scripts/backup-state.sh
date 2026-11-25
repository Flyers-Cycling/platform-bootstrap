#!/usr/bin/env bash
# Save a dated copy of the current state to the R2 bucket (R2 has no versioning).
# Needs: tofu initialised, AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY (the R2 token), aws CLI.
set -euo pipefail
cd "$(dirname "$0")/.."

ENDPOINT="https://ccfd89f34d2e2f3f9a6ee709eb156f44.r2.cloudflarestorage.com"
BUCKET="flyers-tofu-state"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

tofu -chdir=terraform state pull > "$TMP"
if [ ! -s "$TMP" ]; then
  echo "State is empty (first apply?); nothing to back up."
  exit 0
fi
AWS_DEFAULT_REGION=auto aws s3 cp "$TMP" "s3://${BUCKET}/backups/${STAMP}.tfstate" --endpoint-url "$ENDPOINT"
echo "Saved backups/${STAMP}.tfstate"
