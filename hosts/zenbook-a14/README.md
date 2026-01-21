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



