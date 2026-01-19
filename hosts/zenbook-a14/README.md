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
sudo insmod hid-asus-ec.ko
```



