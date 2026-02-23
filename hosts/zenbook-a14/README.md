# NOTE: This device running snapdragon chip so have some problem

# FIX:  Connect to internet when boot
- Connect usb with smartphone to share internet 

# FIX: wifi
[url](https://github.com/alexVinarskis/linux-x1e80100-zenbook-a14)
# FIX: battery
```bash
sudo apt install ubuntu-x1e-settings -y
sudo apt install qcom-firmware-extract -y
sudo qcom-firmware-extract
```
# FIX: fn function
[url](https://github.com/serdeliuk/zenbook-a14-EC)
```bash
cd /tmp
git clone https://github.com/serdeliuk/zenbook-a14-EC.git
cd zenbook-a14-EC
make
# Temporarily load the driver
sudo insmod hid-asus-ec.ko
# Install the driver permanently
sudo cp hid-asus-ec.ko /lib/modules/$(uname -r)/kernel/drivers/hid/
sudo depmod -a
sudo modprobe hid-asus-ec
echo "hid-asus-ec" | sudo tee -a /etc/modules
```
# FIX: audio
[url](https://github.com/alexVinarskis/linux-x1e80100-zenbook-a14?tab=readme-ov-file#audio-configuration)
This repo said that audio works with latest upstream alsa-ucm-config, linux-firmware
## Audioreach-topology
```bash
git clone https://github.com/linux-msm/audioreach-topology/
cd audioreach-topology
cmake .
cmake --build .
sudo cp qcom/x1e80100/ASUSTeK/zenbook-a14/X1E80100-ASUS-Zenbook-A14-tplg.bin /lib/firmware/updates/qcom/x1e80100/X1E80100-ASUS-Zenbook-A14-tplg.bin
```
## Alsa configuration
```bash
curl -L -o alsa-ucm-conf.tar.gz https://github.com/alsa-project/alsa-ucm-conf/archive/refs/heads/master.tar.gz
tar xvzf alsa-ucm-conf.tar.gz
sudo tar xvzf alsa-ucm-conf.tar.gz -C /usr/share/alsa --strip-components=1 --wildcards "*/ucm" "*/ucm2"
```



