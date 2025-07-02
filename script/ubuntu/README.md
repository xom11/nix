```
sudo apt update
sudo apt upgrade -y
```
# SSH
```
sudo apt install openssh-server
sudo systemctl enable --now ssh
```
# KEYD
```
sudo add-apt-repository ppa:keyd-team/ppa
sudo apt update -y
sudo apt install keyd -y
sudo systemctl enable --now keyd