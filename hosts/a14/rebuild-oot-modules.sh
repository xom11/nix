#!/usr/bin/env bash
# Rebuild the out-of-tree kernel modules for the ASUS Zenbook A14 (x1p42100).
#
#   * platform_profile  — stock module refuses to init on this DT-only ARM64
#                         machine (`if (acpi_disabled) return -EOPNOTSUPP;`),
#                         so asus_zenbook_a14_ec can never resolve
#                         devm_platform_profile_register(). Patched copy built
#                         from linux-source.
#   * asus_zenbook_a14_ec — hwmon (fan, temp) + platform_profile
#   * hid_asus_ec         — Fn hotkeys + keyboard backlight
#
# Modules go to /lib/modules/<version>/updates/, which depmod prefers over
# kernel/, so nothing distro-owned is overwritten and `rm` + `depmod -a` undoes
# it. They live under a single kernel version — RE-RUN THIS AFTER EVERY KERNEL
# UPGRADE.
set -euo pipefail

KVER="$(uname -r)"                # 7.0.0-27-generic
SRCVER="${KVER%%-*}"              # 7.0.0
BUILD="${BUILD_DIR:-$HOME/build}"
EC_REPO=https://github.com/Sombre-Osmoze/asus-zenbook-a14-ec.git

if [ "$(cat /sys/kernel/security/lockdown 2>/dev/null | grep -o '\[[a-z]*\]')" != "[none]" ]; then
    echo "kernel lockdown is active; unsigned modules will not load" >&2
    exit 1
fi

echo "==> deps"
sudo apt-get install -y --no-install-recommends \
    build-essential git "linux-headers-$KVER" "linux-source-$SRCVER"

echo "==> EC sources"
if [ -d "$BUILD/ec/.git" ]; then
    git -C "$BUILD/ec" pull --ff-only
else
    mkdir -p "$BUILD"
    git clone --depth 1 "$EC_REPO" "$BUILD/ec"
fi

echo "==> patched platform_profile"
rm -rf "$BUILD/src" "$BUILD/pp"
mkdir -p "$BUILD/src" "$BUILD/pp"
tar -xf "/usr/src/linux-source-$SRCVER/linux-source-$SRCVER.tar.bz2" \
    -C "$BUILD/src" --wildcards '*/drivers/acpi/platform_profile.c'
(
    cd "$BUILD/src/linux-source-$SRCVER"
    patch -p1 < "$BUILD/ec/patches/0001-platform_profile-allow-non-ACPI-systems.patch"
    grep -q 'if (acpi_disabled)' drivers/acpi/platform_profile.c &&
        { echo "patch did not remove the acpi_disabled guard" >&2; exit 1; }
    cp drivers/acpi/platform_profile.c "$BUILD/pp/"
)
echo 'obj-m += platform_profile.o' > "$BUILD/pp/Kbuild"
make -C "/lib/modules/$KVER/build" M="$BUILD/pp" modules

echo "==> EC modules"
make -C "$BUILD/ec"

echo "==> install into /lib/modules/$KVER/updates/"
for ko in "$BUILD/pp/platform_profile.ko" \
          "$BUILD/ec/asus_zenbook_a14_ec.ko" \
          "$BUILD/ec/hid_asus_ec.ko"; do
    sudo install -D -m 0644 "$ko" "/lib/modules/$KVER/updates/$(basename "$ko")"
done
sudo depmod -a

echo "==> load"
sudo modprobe -r asus_zenbook_a14_ec hid_asus_ec platform_profile 2>/dev/null || true
sudo modprobe asus_zenbook_a14_ec
sudo modprobe hid_asus_ec

# Only hid_asus_ec is autoloaded. asus_zenbook_a14_ec wedges the first EC read
# after a warm reboot and takes the machine down with it — see the README.
printf 'hid_asus_ec\n' | sudo tee /etc/modules-load.d/zenbook-a14-ec.conf >/dev/null
printf 'blacklist asus_zenbook_a14_ec\n' |
    sudo tee /etc/modprobe.d/zenbook-a14-ec-noauto.conf >/dev/null

echo "==> verify"
cat /sys/class/platform-profile/platform-profile-0/profile
grep -l asus_zenbook_a14_ec /sys/class/hwmon/hwmon*/name |
    while read -r n; do d="${n%/name}"; echo "fan $(cat "$d/fan1_input") RPM, $(( $(cat "$d/temp1_input") / 1000 ))C"; done
ls /sys/class/leds/ | grep kbd
