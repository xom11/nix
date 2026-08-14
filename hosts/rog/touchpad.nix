{ pkgs, ... }:
{
  # Touchpad ELAN1203 (I2C-HID) KHONG len sau khi boot. Do tren may 14/08/2026:
  #
  #   [ 5.325] i2c_hid_acpi i2c-ELAN1203:00: can't add hid device: -22
  #   [ 5.325] i2c_hid_acpi i2c-ELAN1203:00: probe ... failed with error -22
  #
  # -22 la -EINVAL: driver doc HID descriptor truoc khi thiet bi san sang. Khong
  # co thiet bi input nao duoc tao, nen GNOME khong co gi de doc — trieu chung
  # nhin y het "GNOME khong nhan touchpad", va di tim o tang libinput/Wayland
  # thi khong bao gio ra.
  #
  # Nap lai module sau khi he thong on dinh thi probe THANH CONG:
  #   [554.119] input: ELAN1203:00 04F3:307A Touchpad ...
  #   hid-multitouch 0018:04F3:307A.0004: I2C HID v1.00
  #
  # Vong lap kiem TRUOC khi nap lai, nen neu mot ngay nao do probe luc boot tu
  # chay duoc (kernel moi, BIOS moi) thi service nay thoat ngay va khong dung
  # vao gi. Workaround tu vo hieu khi khong con can — dung de lai rac im lang.
  systemd.services.elan-touchpad-reload = {
    description = "Reload i2c_hid_acpi to work around the ELAN1203 probe race";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.kmod ];
    script = ''
      for _ in 1 2 3 4 5; do
        if grep -q ELAN1203 /proc/bus/input/devices; then
          echo "ELAN1203 present, nothing to do"
          exit 0
        fi
        modprobe -r i2c_hid_acpi || true
        sleep 2
        modprobe i2c_hid_acpi || true
        sleep 2
      done
      echo "ELAN1203 still absent after 5 attempts" >&2
      exit 1
    '';
  };
}
