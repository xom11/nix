# termux — Android phone (Termux · not Nix)

Fresh phone, one command — refreshes the stale bootstrap index (else `pkg install`
404s), then installs openssh, clones the repo, wires SSH aliases over Tailscale,
auto-sets login password `1`, installs a Nerd Font:

```sh
apt update -y -o Dpkg::Options::=--force-confnew && apt full-upgrade -y -o Dpkg::Options::=--force-confnew && pkg install -y curl && curl -fsSL https://raw.githubusercontent.com/xom11/nix/main/hosts/termux/install.sh | sh
```

Nothing prompts: `-y` answers apt's `[Y/n]`, `--force-confnew` answers dpkg's
config-file question (which `-y` does *not* cover). If it dies on the mirror
instead, run `termux-change-repo`, pick a nearby one, re-run.

Then run Tailscale on the phone, and open the Termux:Boot app once so sshd
auto-starts after reboot. From another machine: `ssh 9r` (port 8022).
