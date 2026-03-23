#!/usr/bin/env bash
set -e

REPO="https://github.com/lorenzoamir/devcontainers"

echo "Installing devcontainer template..."

# Check for existing .devcontainer
if [ -d ".devcontainer" ]; then
  echo "⚠️  .devcontainer already exists."
  read -p "Overwrite it? (y/N): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 1
  fi
  rm -rf .devcontainer
fi

TMP_DIR=$(mktemp -d)

echo "Cloning template..."
git clone --depth 1 "$REPO" "$TMP_DIR"

echo "Copying .devcontainer..."
mv "$TMP_DIR/.devcontainer" .

# Remove git metadata
rm -rf "$TMP_DIR"

echo "Starting devcontainer..."
devpod-cli up . --ide none

