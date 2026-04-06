# Ubuntu

## Update System

```bash
sudo apt upgrade -y
```

## SSH

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install openssh-server -y
sudo systemctl enable --now ssh
```

## Logind Configuration

Disable lid switch suspend (useful for servers):

```bash
sudo vi /etc/systemd/logind.conf
# Change: HandleLidSwitch=suspend → HandleLidSwitch=ignore
sudo systemctl restart systemd-logind
```

## Boot Target

### Set non-graphical (headless)

```bash
sudo systemctl set-default multi-user.target
```

### Set graphical (desktop)

```bash
sudo systemctl set-default graphical.target
```
