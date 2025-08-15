```
sudo apt upgrade -y
```
# SSH
```
sudo apt update && sudo apt upgrade -y
sudo apt install openssh-server -y
sudo systemctl enable --now ssh
```
# Other Setup
## Logind Configuration
```
sudo vi /etc/systemd/logind.conf
#HandleLidSwitch=suspend -> HandleLidSwitch=ignore
sudo systemctl restart systemd-logind
```
## non-graphical target
```
sudo systemctl set-default multi-user.target
```
```
sudo systemctl set-default graphical.target
```