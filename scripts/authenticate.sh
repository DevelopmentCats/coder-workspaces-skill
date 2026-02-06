#!/bin/bash
# Authenticate Coder CLI with session token
# Usage: ./authenticate.sh
#
# Logs in using CODER_SESSION_TOKEN.
# Run this when: auth expired, token rotated, or after fresh install.
#
# Requires: CODER_URL and CODER_SESSION_TOKEN environment variables

set -e

if [ -z "$CODER_URL" ]; then
  echo "Error: CODER_URL is not set" >&2
  exit 1
fi

if [ -z "$CODER_SESSION_TOKEN" ]; then
  echo "Error: CODER_SESSION_TOKEN is not set" >&2
  echo "Get a token from: $CODER_URL/cli-auth" >&2
  exit 1
fi

echo "Authenticating to $CODER_URL..."
coder login --token "$CODER_SESSION_TOKEN" "$CODER_URL"

echo
echo "Authenticated as:"
coder whoami
