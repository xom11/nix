```
sudo apt upgrade -y
```
# SSH
```
sudo apt install openssh-server -y
sudo systemctl enable --now ssh
```
# KEYD
```
sudo add-apt-repository ppa:keyd-team/ppa
sudo apt update -y
sudo apt install keyd -y
sudo systemctl enable --now keyd
sudo mkdir -p /etc/keyd
sudo touch /etc/keyd/default.conf
echo '[ids]
*

[main]
capslock=overload(hyper, esc)

[otherlayer]

[hyper:C-M-A]' | sudo tee /etc/keyd/default.conf > /dev/null
sudo systemctl restart keyd
```
# Brave
```
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
sudo apt update -y
sudo apt install brave-browser -y
```
# Vscode
```
sudo apt-get install wget gpg -y
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
sudo apt install -y apt-transport-https
sudo apt update
sudo apt install -y code
```
# TailScale
```
curl -fsSL https://tailscale.com/install.sh | sh
```
# Podman
```
sudo apt-get update -y
sudo apt-get install -y podman
```
# Docker
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Manage Docker as a non-root user
sudo usermod -aG docker $USER
newgrp docker
```
# Other Setup
## Logind Configuration
```
sudo gedit /etc/systemd/logind.conf
```
## non-graphical target
```
sudo systemctl set-default multi-user.target
```
```
sudo systemctl set-default graphical.target
```