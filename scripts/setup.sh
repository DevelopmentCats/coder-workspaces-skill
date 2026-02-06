#!/bin/bash
# Install or update Coder CLI from your instance
# Usage: ./setup.sh
#
# Downloads the binary directly (no shell script execution).
# Ensures version matches your Coder server.
#
# Requires: CODER_URL environment variable

set -e

if [ -z "$CODER_URL" ]; then
  echo "Error: CODER_URL is not set" >&2
  echo 'Set it: export CODER_URL="https://your-coder-instance.com"' >&2
  exit 1
fi

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  BINARY="coder-linux-amd64" ;;
  aarch64) BINARY="coder-linux-arm64" ;;
  armv7l)  BINARY="coder-linux-armv7" ;;
  *)       echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

echo "Downloading Coder CLI from $CODER_URL..."
TMP_BIN=$(mktemp)
curl -fsSL "$CODER_URL/bin/$BINARY" -o "$TMP_BIN"
chmod +x "$TMP_BIN"

echo "Installing to /usr/local/bin/coder..."
sudo mv "$TMP_BIN" /usr/local/bin/coder

echo
echo "Installed:"
coder version
