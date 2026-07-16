#!/data/data/com.termux/files/usr/bin/sh
# hosts/termux/install.sh
#
# One-shot Termux bootstrap for the phone:
#   1. pkg update && pkg upgrade
#   2. install openssh (client + sshd) + git
#   3. clone/pull this repo, symlink ~/.ssh/config -> the repo's ssh config
#      (single source of truth -- edit the repo, `git pull`, done; no rewrite here)
#   4. set a login password and start sshd (incoming, port 8022)
#
# Auth is password-based for now -- no keys yet.
# Run Tailscale on the phone first, then:  sh install.sh
# Safe to re-run: it pulls instead of re-cloning and re-points the symlink.

set -eu

REPO_URL="https://github.com/xom11/nix.git"
REPO_DIR="$HOME/.nix"
SSH_CONFIG_SRC="$REPO_DIR/home-manager/programs/ssh/config"

log() { printf '\n\033[1;32m>>> %s\033[0m\n' "$1"; }

# --- 1. Update system ---------------------------------------------------------
log "Updating packages (pkg update && pkg upgrade)..."
pkg update -y
pkg upgrade -y

# --- 2. Install OpenSSH + git --------------------------------------------------
log "Installing openssh + git..."
pkg install -y openssh git

# --- 3. Clone/pull repo, symlink ssh config -----------------------------------
if [ -d "$REPO_DIR/.git" ]; then
  log "Updating repo at $REPO_DIR..."
  git -C "$REPO_DIR" pull --ff-only
else
  log "Cloning repo to $REPO_DIR..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Back up a real (non-symlink) config once, then point at the repo file. ssh
# silently ignores the mac/linux-only `Include` lines when those files are
# absent, so the same config works unchanged on Termux.
if [ -e "$HOME/.ssh/config" ] && [ ! -L "$HOME/.ssh/config" ]; then
  mv "$HOME/.ssh/config" "$HOME/.ssh/config.bak"
  log "Backed up existing ~/.ssh/config -> ~/.ssh/config.bak"
fi
ln -sfn "$SSH_CONFIG_SRC" "$HOME/.ssh/config"
log "Symlinked ~/.ssh/config -> $SSH_CONFIG_SRC"

# --- 4. Incoming sshd (port 8022) ---------------------------------------------
# Termux sshd listens on 8022; password auth needs a login password set once.
PW_MARK="$HOME/.ssh/.termux_password_set"
if [ ! -f "$PW_MARK" ]; then
  log "Set a password for incoming ssh logins (port 8022):"
  passwd
  touch "$PW_MARK"
else
  log "Login password already set (delete $PW_MARK to redo 'passwd')."
fi

log "Starting sshd..."
pkill sshd 2>/dev/null || true
sshd

cat <<'EOF'

============================================================
 Done.

 Outgoing (phone -> machine), password-based:
   ssh macmini   ssh airm3   ssh a14   ssh rog   ssh dk   ssh x1
   (aliases come from the repo's ssh config -- edit there, then
    run 'git -C ~/.nix pull' on the phone to refresh.)

 Incoming (machine -> this phone), port 8022:
   ssh 9r                         (already aliased on your machines)
   ssh -p 8022 <phone-tailscale-ip>

 Notes:
   - Tailscale must be running on this phone.
   - Target machines need PasswordAuthentication enabled in their sshd.
   - sshd does NOT auto-start after reboot. For that, install the
     Termux:Boot addon (F-Droid) and have it run 'sshd' on boot.
============================================================
EOF
