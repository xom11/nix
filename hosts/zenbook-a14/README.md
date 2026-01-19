# NOTE: This device running snapdragon chip so have some problem

- wifi are error when bootting
1. Connect usb with smartphone to share internet 
2.
3. https://github.com/alexVinarskis/linux-x1e80100-zenbook-a14

# FIX: wifi
```bash
# Find location of driver on Windows partition
WINDOWS_DRIVER="/media/kln/OS/Windows/System32/DriverStore/FileRepository/qcwlanhmt8380.inf_arm64_fd65e05149fc1f8d/"

sudo mkdir -p /lib/firmware/updates/ath11k/WCN6855/hw2.1
sudo cp ${WINDOWS_DRIVER}/wlanfw20.mbn /lib/firmware/updates/ath11k/WCN6855/hw2.1/amss.bin
sudo cp ${WINDOWS_DRIVER}/regdb.bin /lib/firmware/updates/ath11k/WCN6855/hw2.1/regdb.bin
sudo cp ${WINDOWS_DRIVER}/m3.bin /lib/firmware/updates/ath11k/WCN6855/hw2.1/m3.bin

```
# FIX: battery
```bash
sudo apt install ubuntu-x1e-settings -y
sudo apt install qcom-firmware-extract -y
sudo qcom-firmware-extract
```


