#!/bin/bash
# Install or update Coder CLI from your instance
# Usage: ./setup.sh
#
# Installs CLI from CODER_URL to ensure version matches server.
# Run this when: CLI missing, version mismatch, or need to update.
#
# Requires: CODER_URL environment variable

set -e

if [ -z "$CODER_URL" ]; then
  echo "Error: CODER_URL is not set" >&2
  echo 'Set it: export CODER_URL="https://your-coder-instance.com"' >&2
  exit 1
fi

echo "Installing Coder CLI from $CODER_URL..."
curl -fsSL "$CODER_URL/install.sh" | sh

# Rehash to pick up new binary
hash -r 2>/dev/null || true

echo
echo "Installed:"
coder version
