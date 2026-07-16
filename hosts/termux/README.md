# termux — Android phone (Termux · not Nix)

Fresh install — updates packages, installs openssh, clones the repo, wires SSH
aliases over Tailscale, auto-sets login password `1`, installs a Nerd Font:

```sh
pkg install -y curl && curl -fsSL https://raw.githubusercontent.com/xom11/nix/main/hosts/termux/install.sh | sh
```

Then run Tailscale on the phone, and open the Termux:Boot app once so sshd
auto-starts after reboot. From another machine: `ssh 9r` (port 8022).
