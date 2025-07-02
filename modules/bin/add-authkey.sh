#!/bin/bash

DEST_FILE="$HOME/.ssh/authorized_keys"
mkdir -p "$HOME/.ssh"
touch "$DEST_FILE"

SSH_KEYS=(
"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDa2F5AUDIap76vBbBG84AxMnVe+EpSu++nxhDaNWFhuhlroc3xwp0/KlDARMjekgjsIYhOdMRmt7JZmIJ5+LnM3WQcUvocdZ5OKdmUdSjb6xE99Rr9yhDaMsi/TIUOGTdhT/luFVD6qve5uOTsvvYP6ePlqo3lb3z6f0vKMHKm6D2kOq/kVcD8y0k2a08efgFcQZ4kx6wrH0sczjMFrNo0Ek4UTnqw07yE3RLzgLy0pbFLPnYLzCRDGeqFfDlcr3CwFzHVfMr9WDrgHFJZ9S63+WV/4bWOX5QtrHMJhEfa9D39C5Fl/aaCK0Lv3wWc/lhqBYJjJ5KSFdLYzy4AhKlF9U2nVr7gUpvebRQZZlxwzgwBMUD7/uO0U3gWtMcj5GpUEBSYWIQASU8KO2rzEdHDnKm6YVhpjzolTeiqcYaJbv7uecpmZkWdLH2UVXEVQrtVXy4Vg10rN52/TXqhqF/jQQpSrLNmI+ldPeKYqAkkIoed5iAHKe714f1+vsem+L0= admin@LAPTOP-H7PTO5FK"

"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5g/fDMiLD+Sy+jZnGBiYFKug3v5B+lwyNQpWKk0aDpuKeSBXzmLlJ7ma+/wNyPGaV8rBSh4M3QxcU5R64Xl4TkqfbnW1xdff/oUOJwGXzMDH/H1f+VNNWNOzxs9Ko+9c2QqkQz2zOcxeUmi+Ef3yZVk3TljmPiWoCeh6673q1IKEI9b9a8Mz+fT5rqHA7TJp0iiFwrfhE6mhv0SAoGnSb26sdIII/WlWzsiEvD5bUQPTpTGDTZnORGkdjzBoIIjzm/en1mWsmHCLeT3eW/8naIRlIU9MFtqMXd3boaivbAaZ6Nk/+yjRzIpxD87RucYWrMrmJ0OzLLzAkhmwnF48dDUpbqdllVKCR3kHv1jHVcelMscl6u+nYdJEjX2pcosEWSG6YAzFPMboB6ck8ZxHhTlQ6NRMuAKJ9RCtKfXrbDW8eszFGK2w4crr8mYF8fIqGxwvBTFA5G62FShzWj3wDVN0k+v+HAIxvxDkZNc4uxs7gji0sTLwTOJvvByuHU60= macbookpro@MacBook-Pro-cua-Macbook.local"

"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDEXvxIw6DckDXhbt650gz0sthGm8xyt+PGfJ5OUA3x nixos"

"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtklD5ou04FnuluU8mT+YhryqPzOq/p/Zds3DQQ+IN2 macmini"

 
"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPYQkiHfOqKoh8b9N29ioM9UTKE/tO0jBjyi92d3fruNDm2o9ZQukSQcRKF67ue6EXjklPMhPaNRaDwOWf9aGQjBb4x8YpLA/n3QunXlEO8EHzZCuLnoN8PeK2pXNrQAAGmgPY8nxu30J/+t43wiSreXkkz9B+5qupNW21rxitqmzviBnceac8zUlVXDZer+5Z4ZuV2JifdBogXuZqVz9TuP+tOgRjuQK4T/fyz0CxK+F19BgqfcP5l1Qcw1hLaN1y6Eh5NrRpkrjf+ZkYAoKOya4Z8pvyg61S3SYK9hFhZ0Qn06bna9q0YDthrWEoWzA8lpwrtsflzhvU9qdBicXY7Y5eGZq+MyBl+YzcJtdbJ9FNpfP4z3W2x09oxDORz71VRl9vUBGYLSAVO5fu+ER5/hfSUUqnlAjAlpFN8xQ/5S9A4Q2/RQWRWlqC3tsqzw6TEXuQB70zUVdTFwsUO1ZxG6lAmeV1pRepBEiaN9E4nGJ4TEL1bnsADkD5FdmdCa8T0QLCSLeAXN+rIcXOgrFslp2bpNeZr46DRTYg4R4xL8V/zW4tJKY0LOyU5UPjGjkx0/CEs7WxIns/7puvGLd61qwMR72y9t/FelgBLrVQ8Vlm/2/Yq55pa00FpFNd79NDk3ZD+ob115A2oBb7NP+LbX6NTZJcB0jNQzozhgXLuw== phong.nt.1312002@gmail.com"
 		
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