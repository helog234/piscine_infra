#!/bin/bash

# Check input
if [ $# -ne 1 ]; then
  echo "Usage: $0 /path/to/public_key.pub"
  exit 1
fi

KEY_FILE="$1"

# Validate file exists
if [ ! -f "$KEY_FILE" ]; then
  echo "Error: File '$KEY_FILE' not found!"
  exit 1
fi

# Define target user and SSH directory
TARGET_USER="admin"
SSH_DIR="/home/$TARGET_USER/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# Create .ssh directory if it doesn't exist
sudo -u "$TARGET_USER" mkdir -p "$SSH_DIR"
sudo -u "$TARGET_USER" chmod 700 "$SSH_DIR"

# Append key to authorized_keys
cat "$KEY_FILE" | sudo -u "$TARGET_USER" tee -a "$AUTHORIZED_KEYS" > /dev/null

# Set correct permissions
sudo -u "$TARGET_USER" chmod 600 "$AUTHORIZED_KEYS"

echo "✅ SSH key added for user $TARGET_USER."
