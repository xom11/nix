#!/bin/bash

echo "=== Granting passwordless sudo privileges to current user ==="
# The sudo rule we want to add (no password for all commands)
SUDO_RULE="$USER ALL=(ALL) NOPASSWD: ALL"

# Check if the rule already exists in sudoers
if sudo grep -qF "$SUDO_RULE" /etc/sudoers; then
    echo "Sudo privileges already exist for current user, no changes needed."
else
    # Safely append the rule to sudoers using tee
    echo "$SUDO_RULE" | sudo tee -a /etc/sudoers > /dev/null
    echo "Granted passwordless sudo privileges to current user."
fi
echo "-----------------------------------------"