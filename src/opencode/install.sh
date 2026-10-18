#!/bin/bash
set -e

echo "Installing OpenCode..."

VERSION="${VERSION:-latest}"

# Make sure npm is available
if ! command -v npm >/dev/null 2>&1; then
    echo "ERROR: npm is required to install OpenCode."
    echo "Please install Node.js/npm before using this Feature."
    exit 1
fi

if [ "${VERSION}" = "latest" ]; then
    # npm install -g opencode-ai
    curl -fsSL https://opencode.ai/v2/install | bash
else
    # npm install -g "opencode-ai@${VERSION}"
    curl -fsSL https://opencode.ai/v2/install | bash -s -- "--version ${VERSION}"
fi

echo "OpenCode installation completed."

opencode --version