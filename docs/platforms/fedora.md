# Fedora

## Update System

```bash
sudo dnf upgrade --refresh
sudo dnf install -y -q dnf-plugins-core
```

## Bamboo (Vietnamese Input)

```bash
sudo dnf config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:lamlng/Fedora_42/home:lamlng.repo
sudo dnf install -y -q ibus-bamboo
```

## Kitty

```bash
sudo dnf install -y -q kitty
```

## Brave Browser

```bash
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo dnf install -y -q brave-browser
sudo ln /usr/bin/brave-browser-stable /usr/bin/brave
```

## VS Code

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
dnf check-update
sudo dnf install -y -q code
```

## SSH

```bash
sudo dnf install -y -q openssh-server
sudo systemctl enable --now sshd
sudo firewall-cmd --add-service=ssh --permanent
sudo firewall-cmd --reload
```

## Tailscale

```bash
sudo dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
sudo dnf install -y -q tailscale
sudo systemctl enable --now tailscaled
```

## Docker

```bash
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y -q docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```
