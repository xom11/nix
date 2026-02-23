1. Installation ( bootstrapping )
```
curl -L https://raw.githubusercontent.com/kln-os/nix/refs/heads/main/hosts/vmware/install.sh | sh
```
2. Reboot
3. Setup ( rebuild switch)
```
curl -L https://raw.githubusercontent.com/kln-os/nix/refs/heads/main/hosts/vmware/setup.sh | sh
```

# BUG
it has a lot of bugs, wastes too much time, and doesn't run perfectly.
## VMware
- logout and login to make high-DPI work properly
## UTM
- remove iso image to boot in nixos when finish install 
# NOTE
- using NVMe (storage device)
