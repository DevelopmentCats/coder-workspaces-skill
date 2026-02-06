#!/bin/bash
# List available presets for a Coder template
# Usage: ./list-presets.sh <template-name>
#
# Requires: CODER_URL and CODER_SESSION_TOKEN environment variables

set -e

TEMPLATE_NAME="${1:?Usage: $0 <template-name>}"

if [ -z "$CODER_URL" ] || [ -z "$CODER_SESSION_TOKEN" ]; then
  echo "Error: CODER_URL and CODER_SESSION_TOKEN must be set" >&2
  exit 1
fi

# Get the template's active version ID
VERSION_ID=$(curl -sf -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
  "$CODER_URL/api/v2/organizations/coder/templates" | \
  jq -r ".[] | select(.name == \"$TEMPLATE_NAME\") | .active_version_id")

if [ -z "$VERSION_ID" ] || [ "$VERSION_ID" = "null" ]; then
  echo "Error: Template '$TEMPLATE_NAME' not found" >&2
  exit 1
fi

# Get presets for that version
PRESETS=$(curl -sf -H "Coder-Session-Token: $CODER_SESSION_TOKEN" \
  "$CODER_URL/api/v2/templateversions/$VERSION_ID/presets")

if [ "$(echo "$PRESETS" | jq 'length')" -eq 0 ]; then
  echo "No presets found for template '$TEMPLATE_NAME'"
  exit 0
fi

echo "Presets for '$TEMPLATE_NAME':"
echo "$PRESETS" | jq -r '.[] | "  - \(.Name)\(.Default | if . then " (default)" else "" end)"'
