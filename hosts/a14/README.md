# ASUS ZenBook A14 (UX3407QA) — Linux on Snapdragon X Plus

## Rebuild

User config — home-manager (shell alias: `update`):

```sh
home-manager switch --impure -b backup --flake ~/.nix#a14
```

System config — system-manager (shell alias: `system-manager-update`):

```sh
sudo nix run 'github:numtide/system-manager' -- switch --flake ~/.nix#a14
```


Verified on **Ubuntu 26.04 LTS "resolute", kernel `7.0.0-27-generic`**
(`linux-image-generic-hwe-26.04`), 2026-07-10. Boots to the desktop in ~7.2 s.

| Component | Status | Needs |
|---|---|---|
| Display / GPU (Adreno X1-45) | works | dracut config (§3) |
| CPU frequency scaling | works | module + governor (§4) |
| Audio (speakers, mics, jack) | works | Windows firmware (§2) |
| Battery / charging | works | Windows firmware (§2) |
| Bluetooth | works out of the box | — |
| NVMe, touchpad, keyboard, USB-C | work out of the box | — |
| Wi-Fi (WCN6855, NFA725A) | works — but the PCIe link fails to train on ~1 boot in 3 (§5) | Windows firmware + repacked board file (§5) |
| Fn keys, kbd backlight | works | out-of-tree module (§6) |
| Fan, temp, power profile | works, but **must be loaded by hand** (§6) | out-of-tree module (§6) |
| Webcam, hardware video decode | do not work | needs a patched kernel (§7) |

## Read this before changing anything

### The stock Ubuntu kernel is enough — except possibly for Wi-Fi

An older version of this file told you to install `ppa:ubuntu-concept/x1e`'s
`linux-qcom-x1e`. As of kernel 7.0 the **stock** Ubuntu kernel already carries
the `x1p42100-asus-zenbook-a14-lcd` device tree, the `msm`/Adreno driver and
SCMI cpufreq, so you do not need the PPA for GPU, cpufreq or power. Everything
below is written for the stock kernel, and works on it.

**But:** the flaky Wi-Fi PCIe link (§5) has *not* been tested against
`linux-qcom-x1e`, and there is real reason to think that kernel fixes it — see
"The one thing left to try" in §5. Do not repeat the old file's mistake in the
other direction and assume the PPA is worthless.

### How to debug this machine

Both times something killed the boot on this laptop, the answer was already
sitting in the persistent journal, and both times guessing first cost hours.

1. **Read the dead boot's own journal.** `journalctl --list-boots` shows short
   boots. For each one, `journalctl -k -b -N -o short-monotonic | tail` gives
   the last kernel line before the machine died — that line named the culprit
   in both cases (`asus_zenbook_a14_ec`, then `Bluetooth: hci0`). Correlate
   across boots before forming a theory:
   `for b in 0 -1 -2 …; do journalctl -k -b $b | grep -c '<marker>'; done`.

2. **A hard hang leaves no panic and no kdump**, even though `efi_pstore` is
   registered and `crashkernel=` is reserved. Absence of a dump tells you
   nothing. That is why `quiet` and `splash` are stripped from the command
   line (§8) — the console is the only witness.

3. **Ubuntu 26.04 uses `dracut`, not `initramfs-tools`.** `update-initramfs` is
   a shim that calls dracut. Anything in `/etc/initramfs-tools/hooks/` is
   silently ignored. Use `/etc/dracut.conf.d/*.conf`.

4. **Over SSH you cannot see the GPU or the sound card.** `/dev/dri/renderD128`
   is `root:render`, `/dev/snd/*` is `root:audio`; both are handed to the *seat*
   user by a logind ACL, and an SSH session has no seat. `vulkaninfo` will say
   `llvmpipe` and `aplay -l` will say "no soundcards found" while both work
   perfectly on the desktop. Check with `sudo`, or read `/proc/asound/cards`
   and `/sys/kernel/debug/dri/1/gpu`.

5. **Never put unvalidated code in the early boot path.** Two of the three
   crashes documented here were self-inflicted: autoloading the EC driver (§6)
   and a hand-patched `pwrseq-qcom-wcn.ko` in the initrd (§5). Neither the
   hardware nor stock Ubuntu is at fault. Before a change that affects boot,
   know your escape hatch: the GRUB menu (3 s, §8) offers `7.0.0-14-generic`,
   and `e` at the menu lets you append `systemd.mask=…` or
   `modprobe.blacklist=…` to the kernel line. Keep the fallback kernel's
   `updates/` directory untouched.

6. **`modprobe -r ath11k_pci` hangs forever** after an RDDM firmware crash.

### Hardware IDs

```
SoC        qcom,x1p42100          /proc/device-tree/compatible
Model      ASUS Zenbook A14 (UX3407QA, LCD)
GPU        Adreno X1-45, firmware qcom/gen71500_{sqe.fw,gmu.bin,zap.mbn}
Wi-Fi      WCN6855 hw2.1, NFA725A module, PCI 17cb:1103 subsys 14cd:950a
           WLAN host bridge 1c08000.pci = PCI domain 0004
NVMe       host bridge 1bf8000.pci = PCI domain 0006
Windows    /dev/nvme0n1p14, NTFS, LABEL=OS   (dual boot; firmware source)
```

## 1. First boot — internet

Wi-Fi does not work until §5 is done, and even afterwards it is absent on
roughly one boot in three. Connect a phone over USB and enable USB tethering.

> The USB-C port re-enumerates when the ADSP comes up (§2), which drops the
> tethered NIC and kills your SSH session. The machine is *not* hung. Re-plug
> the phone.

## 2. Proprietary firmware from the Windows partition → audio + battery

`qcom-firmware-extract` is a normal Ubuntu package now (universe). It mounts the
Windows partition read-only, copies 11 firmware files into
`/lib/firmware/updates/qcom/x1p42100/ASUSTeK/zenbook-a14/`, wraps them in a
`.deb`, installs it, and rebuilds the initrd.

```bash
sudo apt install -y ubuntu-x1e-settings qcom-firmware-extract
sudo qcom-firmware-extract
sudo reboot
```

This gives you `qcadsp8380.mbn` and `qccdsp8380.mbn`, without which
`remoteproc0` (adsp) and `remoteproc1` (cdsp) stay `offline` — and with them,
`aplay -l` finds no card and `/sys/class/power_supply/qcom-battmgr-bat` has no
readings.

**Reboot; do not `echo start > /sys/class/remoteproc/remoteproc0/state`.**
Starting the DSP by hand works, but it brings up `pmic_glink` mid-session, which
re-enumerates USB-C and drops your tethered network.

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

## 3. GPU — the Adreno microcode must be inside the initrd

Symptom: software rendering, high idle power, and in `dmesg`

```
msm_dpu …: Direct firmware load for qcom/gen71500_sqe.fw failed with error -2
msm_dpu …: [drm:adreno_request_fw [msm]] *ERROR* failed to load gen71500_sqe.fw
```

Cause: the `50ubuntu-x1e-settings` dracut module force-includes `msm.ko` in the
initrd, so the GPU probes at ~1.77 s — about 0.3 s *before* the root filesystem
is mounted at ~2.07 s. That same dracut module copies `qcom/x1e80100/**` and
`qcom/x1p42100/**` into the initrd, but the Adreno microcode lives at the *top
level* of `qcom/`, so it is left behind. The files are on disk (package
`linux-firmware-qualcomm-graphics`); the initrd simply cannot see them.

```bash
sudo tee /etc/dracut.conf.d/zenbook-a14-adreno.conf >/dev/null <<'EOF'
install_items+=" /usr/lib/firmware/qcom/gen71500_sqe.fw.zst /usr/lib/firmware/qcom/gen71500_gmu.bin.zst "
EOF
sudo update-initramfs -u -k all
sudo reboot
```

Verify (note the `sudo` — see "How to debug this machine"):

```bash
sudo lsinitramfs /boot/initrd.img-$(uname -r) | grep gen71500   # 3 files
sudo journalctl -k -b | grep gen71500        # "loaded … from new location"
sudo vulkaninfo --summary | grep deviceName  # Adreno X1-45
sudo cat /sys/kernel/debug/dri/1/gpu | head -2   # gpu-initialized: 1
```

If a future kernel asks for a differently-named microcode, `dmesg` names the
file; adjust `install_items`.

## 4. CPU frequency scaling

Symptom: `/sys/devices/system/cpu/cpu0/cpufreq/` does not exist, all 8 cores
pinned at one frequency.

Cause: `scmi-cpufreq.ko` is built as a module and carries **no modalias**, so
udev never autoloads it, even though the SCMI firmware interface came up fine.
It is not missing — it just has to be loaded explicitly.

```bash
echo scmi-cpufreq | sudo tee /etc/modules-load.d/scmi-cpufreq.conf

# schedutil, not the ondemand default: the SCMI driver registers energy-model
# perf domains, and only schedutil consumes them.
sudo tee /etc/default/grub.d/zenbook-a14.cfg >/dev/null <<'EOF'
GRUB_CMDLINE_LINUX_DEFAULT="$(printf '%s' "$GRUB_CMDLINE_LINUX_DEFAULT" | sed -e 's/\<quiet\>//g' -e 's/\<splash\>//g') cpufreq.default_governor=schedutil"
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=3
EOF
sudo update-grub
```

(The `sed`, the menu and the missing `quiet splash` are explained in §8.)

Verify: `driver=scmi`, `governor=schedutil`, range 710400–2956800 kHz.

```bash
cd /sys/devices/system/cpu/cpu0/cpufreq && cat scaling_driver scaling_governor cpuinfo_{min,max}_freq
```

## 5. Wi-Fi

Two independent things are missing, and fixing only one gives you a firmware
crash instead of a working card. Then, separately, the PCIe link itself is
unreliable.

### (a) Board data

`dmesg` shows

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

### (b) Firmware

Ubuntu's `ath11k/WCN6855/hw2.1/amss.bin` is the `SILICONZ_LITE` build. It
**cannot parse the Windows board data** and dies with
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

### (c) The PCIe link trains unreliably — not a firmware problem

On **5 of 13 measured boots** (~1 in 3) the `1c08000` host bridge fails link
training and the entire `0004` PCI domain never appears:

```
qcom-pcie 1c08000.pci: error -ETIMEDOUT: cannot initialize host
qcom-pcie 1c08000.pci: probe with driver qcom-pcie failed with error -110
$ lspci | grep -i network      # nothing; only the 0006 NVMe domain exists
```

It happens with and without any of the firmware above, so do not go hunting for
a `board-2.bin` bug when you see this — ath11k never gets a device at all. A
warm reboot or a cold boot just re-rolls the dice; unbinding/rebinding
`qcom-pcie` or `pci-pwrctrl-pwrseq` does nothing. `pwrseq_qcom_wcn` and
`pci_pwrctrl_pwrseq` are loaded and healthy.

What does work, **from a fully booted system**, is asking the platform bus to
probe the device again. It usually takes seconds; one attempt was seen to block
for over two minutes:

```bash
sudo sh -c 'echo 1c08000.pci > /sys/bus/platform/drivers_probe'
```

`/usr/local/sbin/wlan-pcie-retry` wraps that in a three-attempt loop, and
`wlan-pcie-retry.service` runs it `After=multi-user.target`, `Type=simple`,
skipped by `ConditionPathExists=!/sys/bus/pci/devices/0004:01:00.0` when the
link came up on its own. Late and non-blocking on purpose: this write is only
ever exercised from a booted system, and nothing should wait on it.

On a failing boot the machine is otherwise **fine** — you get a usable desktop
without Wi-Fi. (That stops being true if you patch `pwrseq`; see below.)

### (d) Upstream status: known, unfixed

`-110` is `-ETIMEDOUT` from `dw_pcie_wait_for_link()`, which retries
`PCIE_LINK_WAIT_MAX_RETRIES = 10` times at `PCIE_LINK_WAIT_SLEEP_MS = 90` —
about 900 ms, never widened. Since Linux 7.0 that function distinguishes
`-ENODEV` (LTSSM in Detect: no device) and `-EIO` (Poll: device inactive) from
`-ETIMEDOUT`, and only `-ETIMEDOUT` aborts the probe. **So this is not "the card
has not powered up yet"** — training starts and never completes.

The `pwrseq-qcom-wcn` maintainer says so in the comment added by `29da3e8748f9`
("power: sequencing: qcom-wcn: explain why we need the WLAN_EN GPIO hack"):

> some platforms still fail to probe the WLAN controller. This is caused by the
> Qcom PCIe controller and needs a workaround in the controller driver

That workaround does not exist in mainline. No upstream commit targets this, and
no public bug report matches `qcom-pcie 1c08000.pci … error -110` on x1p42100.

### (e) What does NOT work — measured

**Do not raise the WCN6855 `pwup_delay_ms`.** Rebuilding `pwrseq-qcom-wcn.ko`
with `pwup_delay_ms` 50 → 300 and `gpio_enable_delay_ms` 5 → 20, installed into
`updates/`, made things **worse**:

- `-110` went from ~5 of 13 boots to **3 of 4**;
- and each of those three then **killed the machine at ~6.5 s**, right after
  `Bluetooth: hci0` finished initialising, never reaching `graphical.target`.

Wi-Fi and Bluetooth share one WCN6855 and one `pwrseq_qcom_wcn` PMU; the longer
delay apparently makes bringing up the Bluetooth target on a PMU whose WLAN
target failed fatal. The theory was wrong from the start — see (d): `-ETIMEDOUT`
already told us the card was powered. Revert with

```bash
sudo rm /lib/modules/$(uname -r)/updates/pwrseq-qcom-wcn.ko
sudo depmod -a && sudo update-initramfs -u -k all
```

### (f) The one thing left to try: `linux-qcom-x1e`

**This is the most promising lead and it has not been tested.**

`ppa:ubuntu-concept/x1e` publishes `linux-qcom-x1e` **7.0.0-32.32 for
`resolute`**. It is Qualcomm's patched tree — exactly where upstream says the
missing `qcom-pcie` workaround belongs. And the owner of this machine reports
that on every *previous* Ubuntu install here, done by following the old version
of this file (which installed that kernel), **Wi-Fi never dropped across
reboots.**

Test it additively, without touching apt sources or upgrading anything else —
download the `.deb`s from the PPA and `dpkg -i` them, keeping `7.0.0-27-generic`
installed and reachable from the GRUB menu. Then count `-110` over several
boots.

Trade-offs: no security updates from the Ubuntu archive; and the out-of-tree
modules of §6 must be rebuilt for the new kernel version
(`./rebuild-oot-modules.sh`), so Fn keys and the keyboard backlight are missing
until you do.

Also untried, from Qualcomm's generic PCIe link-training guidance (not verified
on this DT): `qcom,refclk-always-on` on the PHY node, and `pcie_aspm=off`.

## 6. EC drivers — fan, temperature, Fn keys, keyboard backlight

Uses [Sombre-Osmoze/asus-zenbook-a14-ec](https://github.com/Sombre-Osmoze/asus-zenbook-a14-ec)
(supersedes `serdeliuk/zenbook-a14-EC`): two out-of-tree modules, plus a patched
`platform_profile.ko`.

`asus_zenbook_a14_ec` calls `devm_platform_profile_register()`, exported by
`platform_profile.ko`. ACPI is off on this machine — `dmesg` says
`ACPI: Interpreter disabled`, and `/sys/firmware/acpi` does not exist — so the
stock module refuses to initialise:

```
$ sudo modprobe platform_profile
modprobe: ERROR: could not insert 'platform_profile': Operation not supported
```

That is the `if (acpi_disabled) return -EOPNOTSUPP;` guard in
`drivers/acpi/platform_profile.c`, still present in 7.0. The repo's
`patches/0001-platform_profile-allow-non-ACPI-systems.patch` removes it and
NULL-guards the `acpi_kobj` dereferences. Only that one module has to be
rebuilt — no kernel rebuild, no reboot. Requires Secure Boot off
(`mokutil --sb-state`); it is off by default here.

Run [`rebuild-oot-modules.sh`](./rebuild-oot-modules.sh). It installs
`linux-source-7.0.0`, extracts just `platform_profile.c`, patches it, builds it
together with the two EC modules, and installs all three into
`/lib/modules/$(uname -r)/updates/`.

> Install into `updates/`, never on top of `kernel/drivers/acpi/`. `depmod`'s
> search order on Ubuntu is `updates ubuntu built-in`, so `updates/` wins, the
> distro file stays intact, and reverting is `rm` + `depmod -a`.

**Re-run the script after every kernel upgrade** — the modules live under
`/lib/modules/<version>/`, so a new kernel simply has none.

### `asus_zenbook_a14_ec` must NOT be autoloaded — it breaks warm reboot

This is the single most important line on this page. Autoloading the EC driver
via `/etc/modules-load.d/` makes `reboot` fail: the machine comes back up, runs
~4.3 s, then hangs or silently resets into a loop. Only holding the power button
and cold-booting recovers it. Windows is unaffected, and a cold boot is always
fine — which is exactly what makes it look like a firmware problem. **It is not.
Stock Ubuntu on this laptop reboots cleanly; this bug is created by loading the
driver.**

The last log line on a dying boot is always the same:

```
asus_zenbook_a14_ec: no thermal zones available; manual mode will fall back to EC temp
```

and the very next thing the driver does — `i2c_transfer()` inside `__ec_rb()`
(`asus_zenbook_a14_ec.c:209`), the first read of the EC — never returns. It
never reaches `online: fan0 tach=…`. Across seven boots the correlation was
total:

| `online: fan0 tach` printed | reached `graphical.target` |
|---|---|
| yes (4 boots) | yes, all 4 |
| no (3 boots) | no, all 3 — hang or reset |

Loading the driver leaves the EC in a state that wedges the *next* warm boot's
first read; a cold boot resets the EC, which is why the first `modprobe` after
power-on always works. Reported upstream:
[issue #1](https://github.com/Sombre-Osmoze/asus-zenbook-a14-ec/issues/1) — the
driver has a `.remove` but no `.shutdown` hook, so nothing quiesces the EC on
the reboot path.

```bash
printf 'hid_asus_ec\n' | sudo tee /etc/modules-load.d/zenbook-a14-ec.conf
echo 'blacklist asus_zenbook_a14_ec' | sudo tee /etc/modprobe.d/zenbook-a14-ec-noauto.conf
```

`hid_asus_ec` (Fn hotkeys, keyboard backlight) goes through i2c-hid, not the EC
bus, and is safe to autoload. With this in place the machine did 5 consecutive
warm reboots at ~7.2 s each.

When you want fan speed, temperature or the performance profile, load it by hand
and unload it before rebooting:

```bash
sudo modprobe asus_zenbook_a14_ec
…
sudo modprobe -r asus_zenbook_a14_ec     # or just poweroff instead of reboot
```

`modprobe -r` runs `.remove()`, and one reboot after a load + unload came up
clean — but that boot never touched the EC again, so whether `.remove()` truly
restores it is **not established**. Treat `poweroff` as the safe path.

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
would fix this. The EC repo also ships `scripts/ppd-bridge.py`, a drop-in D-Bus
replacement for `power-profiles-daemon` — not installed here.

## 7. What does not work, and why

- **Webcam.** The `qcom-camss` ISP binds and creates `/dev/video*`, but the
  `ov02c10` sensor never probes. It needs the device-tree patches from
  [alexVinarskis/linux-x1e80100-zenbook-a14](https://github.com/alexVinarskis/linux-x1e80100-zenbook-a14),
  which are maintained against `linux-next` and which that repo marks WIP and
  "not fully working" on the X1P variant.
- **Hardware video decode.** No `iris`/`venus` driver is present at all —
  `/dev/video*` are camss nodes, not a decoder. Same repo, same WIP status.
- **TPM.** Firmware TPM, unsupported.
- `alejandroqh/qcom-firmware-updater` is **not** useful here: it installs GPU and
  video firmware that `linux-firmware` already ships, plus Iris firmware for a
  driver that does not exist.

## 8. Optional power tweaks

Disable services that are useless on this machine (Docker is not installed):

```bash
sudo systemctl disable --now cups-browsed.service ModemManager.service
```

**Verbose boot.** `/etc/default/grub.d/zenbook-a14.cfg` strips `quiet` and
`splash` and gives GRUB a 3-second menu. Both are deliberate: this machine has
hung during boot with no panic and no dump (§6, §5e), and the GRUB menu is the
only way back to `7.0.0-14-generic`, or to a `systemd.mask=…` /
`modprobe.blacklist=…` escape hatch, without a rescue USB. The drop-in edits
`GRUB_CMDLINE_LINUX_DEFAULT` with `sed` instead of reassigning it, so the
`crashkernel=` reservation that `kdump-tools.cfg` appends — it sorts earlier —
is not clobbered.

For diagnosing a silent boot-time reset (like §10), temporarily append
`initcall_debug loglevel=8 log_buf_len=8M` to the kernel line at the GRUB menu
(`e` key) before hitting Ctrl+X. Every driver probe is logged with its duration;
the line before the machine dies names the culprit. Remove these parameters once
you have the evidence — they slow boot by ~0.5 s and consume extra ring-buffer
memory.

**PCIe ASPM.** `pcie_aspm.policy` is a runtime-writable module parameter, so test
it before committing it to GRUB:

```bash
cat /sys/module/pcie_aspm/parameters/policy          # [default] … powersupersave
echo powersupersave | sudo tee /sys/module/pcie_aspm/parameters/policy
# exercise NVMe + Wi-Fi, then check for AER / nvme resets / ath11k errors
sudo dmesg | grep -icE 'AER|nvme.*(error|reset)|ath11k.*(crash|fail)'
echo default | sudo tee /sys/module/pcie_aspm/parameters/policy   # revert
```

`powersupersave` was stable here (NVMe reads/writes and Wi-Fi scans clean, zero
PCIe errors), but the idle-power benefit was **not measured** — the laptop was on
AC, and `power_now` then reports charging power, not system draw. Measure
unplugged first:

```bash
upower -i /org/freedesktop/UPower/devices/battery_qcom_battmgr_bat | grep energy-rate
```

To make it permanent, append `pcie_aspm.policy=powersupersave` to the
`GRUB_CMDLINE_LINUX_DEFAULT` line in `/etc/default/grub.d/zenbook-a14.cfg` and
run `sudo update-grub`.

## 9. GDM login loop after `home-manager switch`

Symptom: you type your password, the screen blinks, and you are back at the login
screen. `journalctl -b -u gdm` shows `GdmDisplay: Session never registered,
failing`, and some user service logs `No GSettings schemas are installed on the
system`.

Cause: `home-manager/base/ubuntu/default.nix` writes
`~/.config/environment.d/99-nix-path.conf`. systemd's *user* manager starts with
no `XDG_DATA_DIRS`, so a bare `${XDG_DATA_DIRS}` expands to nothing and
`/usr/share` is dropped. GNOME then cannot find
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

## 10. Cold boot failure — Ubuntu doesn't boot; power-cycling or Windows first fixes it

Symptom: pressing the power button to cold-boot into Ubuntu shows the ASUS logo and
maybe kernel messages for 2–6 s, then the machine silently resets (no panic, no
oops). On the next cycle the same thing happens — a reset loop until you hold the
power button for a forced off. Booting Windows **first** (any duration), then
shutting Windows down cleanly (Start → Power → Shut down), and **then** cold-booting
into Ubuntu works on the first try.

Reported on UX3407QA + Ubuntu 26.04 + kernel `7.0.0-27-generic`. Not every cold
boot fails — the pattern above describes the state where the machine will *not*
boot Ubuntu at all.

### (a) Root cause hypothesis: incomplete firmware init on cold power-on

The UEFI firmware on the Snapdragon X does the minimum platform init on a cold
power-on. Deeper hardware state — the Embedded Controller (EC), the PMIC voltage
rails, or the PCIe / NVMe link training sequence — requires an OS to bring it into
a fully functional state. Windows does this during its boot and leaves the hardware
in a state that persists across a full shutdown (battery keeps the EC alive, and
some PMIC / PCIe auxiliary power domains stay up). The next cold boot into Ubuntu
then inherits hardware that was already primed by Windows, so every driver probe
succeeds on the first try.

Without Windows, the first cold boot tasks the kernel with initialising hardware
from a "cold" state that the firmware never fully configured. If a probe or a
firmware handshake hangs beyond the UEFI boot watchdog timeout — or causes the PMIC
to trigger a hard reset — the machine reboots with no log.

### (b) Diagnose: capture the failing boot's journal

The console is the only witness (see §0.2). If the journal from a failed boot is
available, it names the culprit the same way it did for `asus_zenbook_a14_ec` and
`Bluetooth: hci0`:

```bash
journalctl --list-boots                         # find the short (<10 s) boot
journalctl -k -b <N> -o short-monotonic | tail  # last kernel line before reset
```

If no journal survives (the reset is too hard or the filesystem was not synced),
`initcall_debug log_buf_len=8M` has been added to the kernel command line via
`/etc/default/grub.d/zenbook-a14.cfg` (run `sudo update-grub` after changing it).
Every driver probe is logged with its duration; the line before the machine dies
names the culprit. A `log_buf_len=8M` buffer helps ensure the early boot messages
are not overwritten before the reset.

Note: this pair of parameters adds ~0.5 s to every boot and uses extra kernel
memory. Once the offender is identified, remove `initcall_debug log_buf_len=8M`
from the `GRUB_CMDLINE_LINUX_DEFAULT` line and re-run `sudo update-grub`.

Check also `pstore` — some resets leave a record there even when the journal dies:

```bash
ls -l /sys/fs/pstore/
cat /sys/fs/pstore/dmesg-efi-* 2>/dev/null | head -50
```

**Known non-fatal errors (present on every boot, do not indicate root cause):**

```
qcom-qmp-usb-phy 88e3000.phy: phy initialization timed-out
phy phy-88e3000.phy.4: phy init failed --> -110
dwc3 a400000.usb: error -ETIMEDOUT: failed to initialize core
dwc3 a400000.usb: probe with driver dwc3 failed with error -110
```

The USB-C PHY fails to initialise because the ADSP (which controls the PMIC
glink for USB-C PD) has not finished booting yet. After the ADSP comes up, USB
works on the second try. This timeout is harmless and can be ignored during
cold boot debugging.

### (c) Immediate workarounds

1.  **Disable Windows Fast Startup.** Boot Windows, open PowerShell as
    Administrator, run `powercfg /h off`. This makes Windows' "Shut down" a true
    S5 power-off instead of a hybrid hibernate. Re-test cold boot into Ubuntu.
    (Fast Startup is on by default on every Windows install; it is the single most
    common source of dual-boot hardware state weirdness on ARM64.)

2.  **Boot Windows first.** Windows → Shut down → immediately select Ubuntu from
    the GRUB menu. This is the known-working path until a deeper fix lands.

3.  **Delay the UEFI watchdog.** Add `efi=debug` to the kernel command line (GRUB
    `e` → append, then Ctrl+X). Some UEFI firmware implementations respond to
    `efi=debug` by turning off the boot watchdog. If the machine now boots, the
    watchdog timeout was the proximate cause.

4.  **Try the PPA kernel.** The `linux-qcom-x1e` kernel from
    `ppa:ubuntu-concept/x1e` ships Qualcomm's PCIe and power-management patches
    that upstream does not carry. See §5f — the procedure (download `.deb`s, keep
    stock kernel as fallback) and the trade-offs (no security updates, rebuild OOT
    modules) are identical.

### (d) Collect & report

If none of the above surfaces the offender, gather:

- `sudo journalctl -k -b -1` from the *next* successful boot (the failed boot is
  the one with the earliest `-b` index that has almost no messages).
- `sudo journalctl -k -b <N>` from every boot that reset.
- A photo of the last 10 lines on the console with `initcall_debug`.
- The output of `sudo cat /sys/firmware/devicetree/base/compatible`
  and `cat /proc/version`.

Then open an issue upstream or at the kernel's
[linux-arm-msm](https://lore.kernel.org/linux-arm-msm/) mailing list with the
hardware IDs from §0.

## 11. Files this setup owns

```
/etc/dracut.conf.d/zenbook-a14-adreno.conf         Adreno microcode -> initrd    (§3)
/etc/default/grub.d/zenbook-a14.cfg                governor, verbose boot, menu  (§4, §8)
/etc/modules-load.d/scmi-cpufreq.conf              cpufreq driver                (§4)
/etc/modules-load.d/zenbook-a14-ec.conf            hid_asus_ec only              (§6)
/etc/modprobe.d/zenbook-a14-ec-noauto.conf         blacklist asus_zenbook_a14_ec (§6)
/etc/modprobe.d/cfg80211-regdom.conf               regulatory domain             (§5)
/etc/systemd/system/wlan-pcie-retry.service        late, non-blocking link retry (§5c)
/usr/local/sbin/wlan-pcie-retry                    its ExecStart; safe by hand   (§5c)
/lib/firmware/updates/ath11k/WCN6855/hw2.1/        board-2.bin, amss.bin, m3.bin (§5)
/lib/firmware/updates/qcom/x1p42100/ASUSTeK/…      ADSP/CDSP, from qcom-firmware-extract (§2)
/lib/modules/$(uname -r)/updates/                  platform_profile, asus_zenbook_a14_ec,
                                                   hid_asus_ec — the EC one is blacklisted (§6)
```

Everything is additive: `/lib/firmware/updates/` and `/lib/modules/*/updates/`
shadow the distro files rather than replacing them. To undo any piece, delete the
file and run `sudo depmod -a` and/or `sudo update-initramfs -u -k all`.
