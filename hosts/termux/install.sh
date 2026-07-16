#!/data/data/com.termux/files/usr/bin/sh
# hosts/termux/install.sh
#
# One-shot Termux bootstrap for the phone:
#   1. pkg update && pkg upgrade
#   2. install openssh (client + sshd) + git + curl
#   3. clone/pull this repo, symlink ~/.ssh/config -> the repo's ssh config
#      (single source of truth -- edit the repo, `git pull`, done; no rewrite here)
#   4. auto-set a login password and start sshd (incoming, port 8022)
#   5. install a Termux:Boot script so sshd auto-starts after reboot
#   6. install a Nerd Font so prompt/file icons render (not boxes)
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
log "Installing openssh + git + curl..."
pkg install -y openssh git curl

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
# Fresh Termux has NO login password, so sshd password auth fails until one is
# set. Termux `passwd` reads stdin and never prompts for a current password, so
# two piped lines set it non-interactively. WEAK on purpose (reachable only over
# your private Tailscale tailnet) -- change LOGIN_PW or run `passwd` for stronger.
LOGIN_PW="1"
log "Setting Termux login password to '$LOGIN_PW' (for incoming ssh on 8022)..."
if printf '%s\n%s\n' "$LOGIN_PW" "$LOGIN_PW" | passwd >/dev/null 2>&1; then
  log "Password set."
else
  log "Auto-set failed -- run 'passwd' manually."
fi

log "Starting sshd..."
pkill sshd 2>/dev/null || true
sshd

# --- 5. Auto-start sshd on boot (Termux:Boot) ---------------------------------
# Needs the Termux:Boot app installed AND opened once so Android registers it.
# termux-wake-lock keeps Android from killing sshd in the background.
BOOT_DIR="$HOME/.termux/boot"
mkdir -p "$BOOT_DIR"
cat >"$BOOT_DIR/start-sshd" <<'BOOT'
#!/data/data/com.termux/files/usr/bin/sh
# Auto-started by Termux:Boot on device boot.
termux-wake-lock
sshd
BOOT
chmod +x "$BOOT_DIR/start-sshd"
log "Installed boot autostart: $BOOT_DIR/start-sshd"

# --- 6. Nerd Font (Termux ships without prompt/icon glyphs) --------------------
# Termux renders a single ~/.termux/font.ttf. Drop in MesloLGS Nerd Font so
# powerline/git/file icons show instead of boxes. Skipped if a font is present.
FONT="$HOME/.termux/font.ttf"
FONT_URL="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
if [ ! -f "$FONT" ]; then
  log "Installing MesloLGS Nerd Font..."
  mkdir -p "$HOME/.termux"
  if curl -fsSL -o "$FONT" "$FONT_URL"; then
    termux-reload-settings 2>/dev/null || true
    log "Nerd Font installed."
  else
    log "Font download failed -- skipping (icons may show as boxes)."
    rm -f "$FONT"
  fi
else
  log "Termux font already present -- leaving it."
fi

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
   login password: 1  (change anytime with: passwd)

 Notes:
   - Tailscale must be running on this phone.
   - Target machines need PasswordAuthentication enabled in their sshd.
   - sshd auto-starts on reboot via ~/.termux/boot/start-sshd.
     Open the Termux:Boot app ONCE so Android enables autostart.
============================================================
EOF
