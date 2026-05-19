# Single source of truth for agenix recipient public keys.
# Consumed by:
#   - ./secrets.nix       (rules for the `agenix` CLI)
#   - ./default.nix       (renders ~/.config/agenix/recipients for the nvim plugin)
# Add a new entry here when a new host needs to decrypt secrets, then rebuild
# and run `agenix -r` from the repo root to re-key existing files.
[
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtklD5ou04FnuluU8mT+YhryqPzOq/p/Zds3DQQ+IN2 macmini"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDEXvxIw6DckDXhbt650gz0sthGm8xyt+PGfJ5OUA3x nixos"
]
