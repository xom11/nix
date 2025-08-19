#!/bin/bash

DEST_FILE="$HOME/.ssh/authorized_keys"
mkdir -p "$HOME/.ssh"
touch "$DEST_FILE"

SSH_KEYS=(
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDEXvxIw6DckDXhbt650gz0sthGm8xyt+PGfJ5OUA3x nixos"

"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtklD5ou04FnuluU8mT+YhryqPzOq/p/Zds3DQQ+IN2 macmini"

"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMeMa2joKyHJV1YyEWRfK+GGXwFtFes6FFe2lsK6q2ro admin@LAPTOP-H7PTO5FK"


"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINUFEYLmh7pGjONKz84iT1pYIXbIwW98nOhOA7Vgu8s9 tapo@User"

"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIiN//X+uB6ZVxSpemZvaBo0X7yMaQu3f6/4SprXFcpf macbookpro@192.168.1.90"
)

echo "=== Updating SSH keys in $DEST_FILE... ==="
# Add SSH keys if they don't already exist
for key in "${SSH_KEYS[@]}"; do
    if ! grep -Fxq "$key" "$DEST_FILE"; then
        echo "$key" >> "$DEST_FILE"
        echo "Added key: $(echo "$key" | cut -d' ' -f3)"
    else
        echo "Key already exists: $(echo "$key" | cut -d' ' -f3)"
    fi
done

# Set secure permissions for authorized_keys
chmod 600 "$DEST_FILE"

echo "SSH keys have been updated!"
echo "-----------------------------------------"
echo "ssh $(whoami)@$(curl -s ifconfig.co)"