# ASUS ZenBook A14 (Snapdragon X Elite)

This device runs a Snapdragon ARM chip (`x1e80100`) with limited Linux support. The fixes below are required after a fresh Ubuntu install.

## Internet (First Boot)

Connect a smartphone via USB tethering — Wi-Fi does not work out of the box.

## Wi-Fi

Follow the driver instructions at [linux-x1e80100-zenbook-a14](https://github.com/alexVinarskis/linux-x1e80100-zenbook-a14).

## Battery

```bash
sudo apt install ubuntu-x1e-settings qcom-firmware-extract -y
sudo qcom-firmware-extract
```

## Power & Fan Control (Unresolved)

Power efficiency is significantly worse than on Windows — battery drains much faster. Fan control does not work; the fan runs at maximum speed at all times regardless of load.

## Fn Keys

Build and install the [zenbook-a14-EC](https://github.com/serdeliuk/zenbook-a14-EC) kernel module:

```bash
cd /tmp
git clone https://github.com/serdeliuk/zenbook-a14-EC.git
cd zenbook-a14-EC
make
sudo insmod hid-asus-ec.ko
sudo cp hid-asus-ec.ko /lib/modules/$(uname -r)/kernel/drivers/hid/
sudo depmod -a
sudo modprobe hid-asus-ec
echo "hid-asus-ec" | sudo tee -a /etc/modules
```

## Audio

Requires upstream `alsa-ucm-conf` and `linux-firmware`. See [audio configuration](https://github.com/alexVinarskis/linux-x1e80100-zenbook-a14?tab=readme-ov-file#audio-configuration).

### Audioreach Topology

```bash
git clone https://github.com/linux-msm/audioreach-topology/
cd audioreach-topology
cmake . && cmake --build .
sudo cp qcom/x1e80100/ASUSTeK/zenbook-a14/X1E80100-ASUS-Zenbook-A14-tplg.bin \
  /lib/firmware/updates/qcom/x1e80100/X1E80100-ASUS-Zenbook-A14-tplg.bin
```

### ALSA UCM Config

```bash
curl -L -o alsa-ucm-conf.tar.gz https://github.com/alsa-project/alsa-ucm-conf/archive/refs/heads/master.tar.gz
sudo tar xvzf alsa-ucm-conf.tar.gz -C /usr/share/alsa --strip-components=1 --wildcards "*/ucm" "*/ucm2"
```
