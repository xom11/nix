# xom11/nix

Personal Nix configurations for macOS, NixOS, and Linux.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/xom11/nix/main/install | sh
```

## Clone

```bash
git clone https://github.com/xom11/nix.git ~/.nix -q --depth 1
```

## Architecture

The flake outputs and the module tree are documented in one place — the repo root —
so they cannot drift apart:

- [`README.md`](https://github.com/xom11/nix/blob/main/README.md) — platforms, rebuild commands, directory layout
- [`CLAUDE.md`](https://github.com/xom11/nix/blob/main/CLAUDE.md) — module system, option paths, how to check a host without rebuilding it

## Troubleshooting

If you get experimental features errors:

```bash
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```
