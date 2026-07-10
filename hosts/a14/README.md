# ASUS ZenBook A14 (UX3407QA) — Linux on Snapdragon X Plus

Verified working on **Ubuntu 26.04 LTS "resolute", kernel `7.0.0-27-generic`** (`linux-image-generic-hwe-26.04`), 2026-07-10.

| Component | Status | Needs |
|---|---|---|
| Display / GPU (Adreno X1-45) | works | dracut config (§3) |
| CPU frequency scaling | works | module + governor (§4) |
| Audio (speakers + mics) | works | Windows firmware (§2) |
| Battery / charging | works | Windows firmware (§2) |
| Wi-Fi (WCN6855, NFA725A) | works | Windows firmware + repacked board file (§5) |
| Fan, temp, Fn keys, kbd backlight | works | out-of-tree modules (§6) |
| Bluetooth, webcam, fingerprint | untested | — |

## Read this before changing anything

The old version of this file targeted an older Ubuntu and told you to install
the `ppa:ubuntu-concept/x1e` kernel (`linux-qcom-x1e`). **That is no longer
needed and you should not do it.** As of kernel 7.0 the stock Ubuntu kernel
already has everything: the `x1p42100-asus-zenbook-a14-lcd` device tree, the
`msm`/Adreno driver, and SCMI cpufreq. The remaining problems are all
*packaging* and *proprietary firmware* problems, not kernel problems.

Three facts that will save you hours:

1. **Ubuntu 26.04 uses `dracut`, not `initramfs-tools`.** `update-initramfs`
   is a compatibility shim that calls dracut. Anything you drop in
   `/etc/initramfs-tools/hooks/` is silently ignored. Use
   `/etc/dracut.conf.d/*.conf` or `/usr/lib/dracut/modules.d/`.

2. **Over SSH you cannot see the GPU or the sound card.** `/dev/dri/renderD128`
   is `root:render` and `/dev/snd/*` is `root:audio`; both are handed to the
   *seat* user via a systemd-logind ACL, and an SSH session has no seat. So
   `vulkaninfo` reports `llvmpipe` and `aplay -l` reports "no soundcards found"
   even when both work perfectly on the desktop. Verify with `sudo`, or read
   `/proc/asound/cards` and `/sys/kernel/debug/dri/1/gpu` instead.

3. **Never `modprobe -r ath11k_pci`.** See §5 — it can wedge the Wi-Fi card so
   that only a full power-off recovers it.

Hardware IDs you will need:

```
SoC        qcom,x1p42100          /proc/device-tree/compatible
Model      ASUS Zenbook A14 (UX3407QA, LCD)
GPU        Adreno X1-45, firmware qcom/gen71500_{sqe.fw,gmu.bin,zap.mbn}
Wi-Fi      WCN6855 hw2.1, NFA725A module, PCI 17cb:1103 subsys 14cd:950a
Windows    /dev/nvme0n1p14, NTFS, LABEL=OS   (dual boot; firmware source)
```

## 1. First boot — internet

Wi-Fi does not work until §5 is done. Connect a phone over USB and enable USB
tethering.

> The USB-C port re-enumerates when the ADSP comes up (§2), which drops the
> tethered NIC and kills your SSH session. The machine is *not* hung. Re-plug
> the phone.

## 2. Proprietary firmware from the Windows partition → audio + battery

`qcom-firmware-extract` is now a normal Ubuntu package (universe). It mounts
the Windows partition read-only, copies 11 firmware files into
`/lib/firmware/updates/qcom/x1p42100/ASUSTeK/zenbook-a14/`, wraps them in a
`.deb`, installs it, and rebuilds the initrd.

```bash
sudo apt install -y ubuntu-x1e-settings qcom-firmware-extract
sudo qcom-firmware-extract
sudo reboot
```

This gives you `qcadsp8380.mbn` and `qccdsp8380.mbn`, without which
`remoteproc0` (adsp) and `remoteproc1` (cdsp) stay `offline` — and with them
`aplay -l` finds no card and `/sys/class/power_supply/qcom-battmgr-bat` has no
readings.

**Reboot; do not `echo start > /sys/class/remoteproc/remoteproc0/state`.**
Starting the DSP by hand works, but it brings up `pmic_glink` mid-session,
which re-enumerates USB-C and drops your tethered network.

Nothing else is needed for audio. The Zenbook A14 topology
(`X1E80100-ASUS-Zenbook-A14-tplg.bin`) and a matching UCM profile already ship
in `linux-firmware` / `alsa-ucm-conf` on 26.04 — **do not** build
`audioreach-topology` or unpack `alsa-ucm-conf` from git, as older guides say.

Verify:

```bash
cat /sys/class/remoteproc/remoteproc*/state     # running, running
cat /proc/asound/cards                          # X1E80100-ASUS-Zenbook-A14
upower -i /org/freedesktop/UPower/devices/battery_qcom_battmgr_bat
```

## 3. GPU — Adreno microcode must be inside the initrd

Symptom: software rendering, ~10 W idle, and in `dmesg`

```
msm_dpu ...: Direct firmware load for qcom/gen71500_sqe.fw failed with error -2
msm_dpu ...: [drm:adreno_request_fw [msm]] *ERROR* failed to load gen71500_sqe.fw
```

Cause: the `50ubuntu-x1e-settings` dracut module force-includes `msm.ko` in the
initrd, so the GPU probes at ~1.77 s — about 0.3 s *before* the root filesystem
is mounted at ~2.07 s. That same dracut module copies `qcom/x1e80100/**` and
`qcom/x1p42100/**` into the initrd, but the Adreno microcode lives at the *top
level* of `qcom/`, so it is left behind. The files exist on disk (package
`linux-firmware-qualcomm-graphics`); the initrd just cannot see them.

```bash
sudo tee /etc/dracut.conf.d/zenbook-a14-adreno.conf >/dev/null <<'EOF'
install_items+=" /usr/lib/firmware/qcom/gen71500_sqe.fw.zst /usr/lib/firmware/qcom/gen71500_gmu.bin.zst "
EOF
sudo update-initramfs -u -k all
sudo reboot
```

Verify (note `sudo` — see "Read this first"):

```bash
sudo lsinitramfs /boot/initrd.img-$(uname -r) | grep gen71500   # 3 files
sudo journalctl -k -b | grep gen71500        # "loaded ... from new location"
sudo vulkaninfo --summary | grep deviceName  # Adreno X1-45
sudo cat /sys/kernel/debug/dri/1/gpu | head -2   # gpu-initialized: 1
```

If a future kernel asks for a differently-named microcode, `dmesg` will name
the file; adjust `install_items` accordingly.

## 4. CPU frequency scaling

Symptom: `/sys/devices/system/cpu/cpu0/cpufreq/` does not exist, all 8 cores
pinned at one frequency.

Cause: `scmi-cpufreq.ko` is built as a module and carries **no modalias**, so
udev never autoloads it even though the SCMI firmware interface came up fine.
It is not missing — it just has to be loaded explicitly.

```bash
echo scmi-cpufreq | sudo tee /etc/modules-load.d/scmi-cpufreq.conf

# schedutil, not the ondemand default: the SCMI driver registers energy-model
# perf domains, which only schedutil consumes.
sudo tee /etc/default/grub.d/zenbook-a14.cfg >/dev/null <<'EOF'
GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT cpufreq.default_governor=schedutil"
EOF
sudo update-grub
```

Verify: `driver=scmi`, `governor=schedutil`, range 710400–2956800 kHz.

```bash
cd /sys/devices/system/cpu/cpu0/cpufreq && cat scaling_driver scaling_governor cpuinfo_{min,max}_freq
```

## 5. Wi-Fi — repacked `board-2.bin` + Windows firmware

Two independent things are missing, and fixing only one gives you a firmware
crash instead of a working card.

**(a) Board data.** `dmesg` shows

```
ath11k_pci: failed to fetch board data for bus=pci,vendor=17cb,device=1103,
  subsystem-vendor=14cd,subsystem-device=950a,qmi-chip-id=2,qmi-board-id=255,
  variant=UX3407Q from ath11k/WCN6855/hw2.1/board-2.bin
```

`variant=UX3407Q` comes from the device tree
(`/proc/device-tree/soc@0/pci@1c08000/pcie@0/wifi@0/qcom,calibration-variant`).
Upstream `board-2.bin` has no `950a` and no `UX3407Q` entry, so you must add
one. The Windows driver names the exact file: `qcwlanhsp8380.inf` maps
`SUBSYS_950A14CD` to section `QcWlan_AS_NFA725a_2_1`, which copies
`bdwlan_wcn685x_2p1_nfa725a_UX3407Q.elf`.

**(b) Firmware.** Ubuntu's `ath11k/WCN6855/hw2.1/amss.bin` is the
`SILICONZ_LITE` build. It **cannot parse the Windows board data** and dies with
`firmware crashed: MHI_CB_EE_RDDM` the moment the BDF is downloaded. You need
Windows' `SILICONZ_WOS` firmware to go with it. `m3.bin` differs too and must
also come from Windows. `regdb.bin` does not — the upstream one is fine.

```bash
sudo apt install -y ntfs-3g python3 zstd
sudo mkdir -p /mnt/win && sudo mount -t ntfs-3g -o ro /dev/nvme0n1p14 /mnt/win
D=$(ls -d /mnt/win/Windows/System32/DriverStore/FileRepository/qcwlanhsp8380.inf_arm64_* | tail -1)

mkdir -p ~/bd && cd ~/bd
curl -fLO https://raw.githubusercontent.com/qca/qca-swiss-army-knife/master/tools/scripts/ath11k/ath11k-bdencoder
chmod +x ath11k-bdencoder
zstd -qdf /lib/firmware/ath11k/WCN6855/hw2.0/board-2.bin.zst -o board-2.bin
./ath11k-bdencoder -e board-2.bin            # -> board-2.json + 120 payloads
cp "$D/bdwlan_wcn685x_2p1_nfa725a_UX3407Q.elf" .

python3 - <<'PY'
import json
BASE = ("bus=pci,vendor=17cb,device=1103,"
        "subsystem-vendor=14cd,subsystem-device=950a")
names = [f"{BASE},qmi-chip-id={c},qmi-board-id=255{v}"
         for v in (",variant=UX3407Q", "") for c in (2, 18)]
doc = json.load(open("board-2.json"))
boards = doc[0]["board"] if isinstance(doc, list) else doc["board"]
boards.append({"names": names,
               "data": "bdwlan_wcn685x_2p1_nfa725a_UX3407Q.elf"})
json.dump(doc, open("board-2.json", "w"), indent=4)
PY

./ath11k-bdencoder -c board-2.json -o board-2-new.bin
./ath11k-bdencoder -i board-2-new.bin | grep UX3407Q     # sanity check

U=/lib/firmware/updates/ath11k/WCN6855/hw2.1
sudo install -D -m0644 board-2-new.bin "$U/board-2.bin"
sudo install -m0644 "$D/wlanfw20.mbn"  "$U/amss.bin"
sudo install -m0644 "$D/m3.bin"        "$U/m3.bin"
sudo umount /mnt/win
sudo reboot
```

Optional, to pin the regulatory domain (`iw reg` otherwise stays at `country 00`):

```bash
echo 'options cfg80211 ieee80211_regdom=VN' | sudo tee /etc/modprobe.d/cfg80211-regdom.conf
```

Verify:

```bash
sudo journalctl -k -b | grep -E 'fw_build_id|RDDM'   # WOS build, zero RDDM
nmcli device wifi list
```

`Failed to set the requested Country regulatory setting` / `failed to process
regulatory info -22` in `dmesg` is benign — scanning and association work.

### The Wi-Fi PCIe link trains unreliably — this is *not* a firmware problem

Roughly two boots in three, the `1c08000` host bridge (the WLAN slot) fails
link training and the **entire `0004` PCI domain never appears**:

```
qcom-pcie 1c08000.pci: probe with driver qcom-pcie failed with error -110
$ lspci | grep -i network      # nothing; only the 0006 NVMe domain exists
```

Measured over 8 boots: `7.0.0-14-generic` 1/1 enumerated, `7.0.0-27-generic`
2/7. It happens with and without any of the firmware above, so do not go
looking for a `board-2.bin` bug when you see this — ath11k never even gets a
device. Things that do **not** help: a warm reboot, a full power-off,
unbinding/rebinding `qcom-pcie`, unbinding/rebinding `pci-pwrctrl-pwrseq`.
`pwrseq_qcom_wcn` and `pci_pwrctrl_pwrseq` are loaded and fine.

What does work is asking the platform bus to probe the device again:

```bash
sudo sh -c 'echo 1c08000.pci > /sys/bus/platform/drivers_probe'
```

This blocks for ~100 s inside `dw_pcie_wait_for_link()` and then the card shows
up. `wlan-pcie-retry.service` automates it — it is skipped when the link came
up on its own:

```ini
# /etc/systemd/system/wlan-pcie-retry.service
[Unit]
Description=Retry the WLAN PCIe host-bridge probe (x1p42100 link trains unreliably)
After=multi-user.target
ConditionPathExists=!/sys/bus/pci/devices/0004:01:00.0

[Service]
Type=simple
ExecStart=/usr/local/sbin/wlan-pcie-retry

[Install]
WantedBy=multi-user.target
```

with `/usr/local/sbin/wlan-pcie-retry` retrying `drivers_probe` up to three
times. `Type=simple` matters: each attempt blocks for ~100 s, so boot must not
wait on it.

Also avoid `modprobe -r ath11k_pci` — after an RDDM firmware crash the unload
hangs indefinitely.

## 6. EC drivers — fan, temperature, Fn keys, keyboard backlight

Uses [Sombre-Osmoze/asus-zenbook-a14-ec](https://github.com/Sombre-Osmoze/asus-zenbook-a14-ec)
(supersedes `serdeliuk/zenbook-a14-EC`). Two out-of-tree modules, plus a patched
`platform_profile.ko`.

`asus_zenbook_a14_ec` calls `devm_platform_profile_register()`, exported by
`platform_profile.ko`. On this machine ACPI is off — `dmesg` says
`ACPI: Interpreter disabled` and `/sys/firmware/acpi` does not exist — so the
stock module refuses to initialise:

```
$ sudo modprobe platform_profile
modprobe: ERROR: could not insert 'platform_profile': Operation not supported
```

That is the `if (acpi_disabled) return -EOPNOTSUPP;` guard in
`drivers/acpi/platform_profile.c`, still present in 7.0. The repo's
`patches/0001-platform_profile-allow-non-ACPI-systems.patch` removes it and
NULL-guards the `acpi_kobj` dereferences. Only that one module has to be
rebuilt — no kernel rebuild, no reboot.

Requires Secure Boot off (`mokutil --sb-state`); it is off by default here.

Run [`rebuild-oot-modules.sh`](./rebuild-oot-modules.sh) — it installs
`linux-source-7.0.0`, extracts just `platform_profile.c`, patches it, builds it
together with the two EC modules, and installs everything into
`/lib/modules/$(uname -r)/updates/`.

```bash
./rebuild-oot-modules.sh
printf 'asus_zenbook_a14_ec\nhid_asus_ec\n' | sudo tee /etc/modules-load.d/zenbook-a14-ec.conf
```

> Install into `updates/`, not on top of `kernel/drivers/acpi/`. `depmod`'s
> search order on Ubuntu is `updates ubuntu built-in`, so `updates/` wins, the
> distro file stays intact, and reverting is `rm` + `depmod -a`.

**Re-run the script after every kernel upgrade.** The modules live under
`/lib/modules/<version>/`, so a new kernel simply has none.

Verify:

```bash
cat /sys/class/platform-profile/platform-profile-0/{profile,choices}
grep . /sys/class/hwmon/hwmon*/name | grep asus_zenbook_a14_ec   # -> hwmonN
cat /sys/class/hwmon/hwmonN/{fan1_input,temp1_input}             # RPM, m°C
ls /sys/class/leds/ | grep kbd                                   # asus::kbd_backlight
```

| Path | Purpose |
|---|---|
| `/sys/class/hwmon/hwmonN/fan1_input` | fan RPM |
| `/sys/class/hwmon/hwmonN/pwm1`, `pwm1_enable` | manual fan PWM (1 = manual, 2 = auto) |
| `/sys/class/hwmon/hwmonN/temp1_input` | EC thermistor (m°C) |
| `/sys/class/platform-profile/platform-profile-0/profile` | `quiet` / `balanced` / `performance` |

### GNOME's Power Mode menu will not drive this

`power-profiles-daemon` 0.30 (26.04) only knows the legacy
`/sys/firmware/acpi/platform_profile` path, which cannot exist on a DT-only
ARM64 machine. It reports `PlatformDriver: placeholder` and offers only
`balanced` / `power-saver`. Switch profiles by writing sysfs directly:

```bash
echo performance | sudo tee /sys/class/platform-profile/platform-profile-0/profile
```

A newer `power-profiles-daemon` that understands `/sys/class/platform-profile/`
fixes this. The EC repo also ships `scripts/ppd-bridge.py`, a drop-in D-Bus
replacement for `power-profiles-daemon` — not installed here.

## 7. Optional power tweaks

Disable services that are useless on this machine (Docker is not installed):

```bash
sudo systemctl disable --now cups-browsed.service ModemManager.service
```

**PCIe ASPM.** `pcie_aspm.policy` is a runtime-writable module parameter, so
test it before committing it to GRUB:

```bash
cat /sys/module/pcie_aspm/parameters/policy          # [default] ... powersupersave
echo powersupersave | sudo tee /sys/module/pcie_aspm/parameters/policy
# exercise NVMe + Wi-Fi, then check for AER / nvme resets / ath11k errors
sudo dmesg | grep -icE 'AER|nvme.*(error|reset)|ath11k.*(crash|fail)'
echo default | sudo tee /sys/module/pcie_aspm/parameters/policy   # revert
```

`powersupersave` was stable here (NVMe reads/writes and Wi-Fi scans clean, zero
PCIe errors) but the idle-power benefit was **not measured** — the laptop was on
AC, and `power_now` then reports charging power, not system draw. Measure
unplugged first:

```bash
upower -i /org/freedesktop/UPower/devices/battery_qcom_battmgr_bat | grep energy-rate
```

To make it permanent, append `pcie_aspm.policy=powersupersave` to the
`GRUB_CMDLINE_LINUX_DEFAULT` line in `/etc/default/grub.d/zenbook-a14.cfg` and
run `sudo update-grub`.

## 8. GDM login loop after `home-manager switch`

Symptom: you type your password, the screen blinks, and you are back at the
login screen. `journalctl -b -u gdm` shows `GdmDisplay: Session never
registered, failing`, and some user service logs `No GSettings schemas are
installed on the system`.

Cause: `home-manager/base/ubuntu/default.nix` writes
`~/.config/environment.d/99-nix-path.conf`. systemd's *user* manager starts
with no `XDG_DATA_DIRS`, so a bare `${XDG_DATA_DIRS}` expands to nothing and
`/usr/share` is dropped from the list. GNOME then cannot find
`/usr/share/glib-2.0/schemas/gschemas.compiled`, `gnome-session` dies, and GDM
gives up on the session.

Fixed in this repo by giving the expansion a default —
`${XDG_DATA_DIRS:-/usr/local/share:/usr/share}`, which `environment.d(5)`
supports. Check with:

```bash
systemctl --user show-environment | grep XDG_DATA_DIRS   # must contain /usr/share
```

This bites *any* Ubuntu host using `modules.home-manager.base.ubuntu.enable`,
not just this one.

## 9. Files this setup owns

```
/etc/dracut.conf.d/zenbook-a14-adreno.conf         Adreno microcode -> initrd   (§3)
/etc/default/grub.d/zenbook-a14.cfg                cpufreq.default_governor      (§4)
/etc/modules-load.d/scmi-cpufreq.conf              cpufreq driver                (§4)
/etc/modules-load.d/zenbook-a14-ec.conf            EC + HID modules              (§6)
/etc/modprobe.d/cfg80211-regdom.conf               regulatory domain             (§5)
/etc/systemd/system/wlan-pcie-retry.service        retry flaky WLAN PCIe link    (§5)
/usr/local/sbin/wlan-pcie-retry                    ^ its ExecStart               (§5)
/lib/firmware/updates/ath11k/WCN6855/hw2.1/        board-2.bin, amss.bin, m3.bin (§5)
/lib/firmware/updates/qcom/x1p42100/ASUSTeK/...    ADSP/CDSP, from qcom-firmware-extract (§2)
/lib/modules/$(uname -r)/updates/                  platform_profile, asus_zenbook_a14_ec, hid_asus_ec (§6)
```

Everything is additive — `/lib/firmware/updates/` and `/lib/modules/*/updates/`
shadow the distro files rather than replacing them. To undo any piece, delete
the file and run `sudo depmod -a` and/or `sudo update-initramfs -u -k all`.
