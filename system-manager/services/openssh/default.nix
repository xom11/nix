{ config, mkModule, ... }:
mkModule config ./. {
  # Ubuntu ships and maintains openssh-server itself (host keys, /etc/pam.d/sshd,
  # ssh.socket), so we keep remote access on that battle-tested distro path
  # rather than running a nixpkgs sshd. This just automates the manual
  # `apt install openssh-server` step of setting up a new machine.
  #
  # preActivationAssertions run as root during `system-manager switch` (it is
  # invoked with sudo). The dpkg guard means apt — and the network — is only
  # touched the first time; later switches skip straight to enable + ufw.
  system-manager.preActivationAssertions.openssh = {
    enable = true;
    script = ''
      export DEBIAN_FRONTEND=noninteractive
      if ! dpkg -s openssh-server >/dev/null 2>&1; then
        apt-get update -qq || true
        apt-get install -y openssh-server
      fi
      # Ubuntu 26.04 uses socket activation; fall back to the service unit.
      systemctl enable --now ssh.socket 2>/dev/null \
        || systemctl enable --now ssh.service 2>/dev/null || true
      # Open port 22 only if ufw is present; the rule is harmless while ufw is
      # inactive (Ubuntu's default) and takes effect if it is ever enabled.
      if command -v ufw >/dev/null 2>&1; then
        ufw allow 22/tcp || true
      fi
    '';
  };
}
