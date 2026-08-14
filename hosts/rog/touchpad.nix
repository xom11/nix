{ pkgs, ... }:
{
  # Touchpad ELAN1203 (I2C-HID) probe TRUOT o lan boot dau sau khi cai
  # (14/08/2026):
  #
  #   [ 5.325] i2c_hid_acpi i2c-ELAN1203:00: can't add hid device: -22
  #
  # -22 la -EINVAL: driver doc HID descriptor truoc khi thiet bi san sang. Khong
  # thiet bi input nao duoc tao, nen GNOME khong co gi de doc — trieu chung nhin
  # y het "GNOME khong nhan touchpad", va di tim o tang libinput/Wayland thi
  # khong bao gio ra. (Phien la Wayland: mutter noi thang voi libinput, khong
  # dinh gi toi xf86-input-libinput.)
  #
  # DO LAI SAU DO: lan boot BINH THUONG ke tiep probe THANH CONG o giay 5.42,
  # khong co loi nao. Lan truot kia di sau chuoi kexec + warm reboot cua buoi
  # cai dat, nen nhieu kha nang la di chung cua no chu khong phai benh co huu.
  #
  # VAN GIU service nay, vi mot lan boot sach KHONG chung minh duoc dieu gi:
  # dua tien trinh o i2c-hid von la loai chap chon. Vong lap kiem
  # /proc/bus/input/devices TRUOC khi dung toi modprobe, nen khi phan cung
  # ngoan no chi grep mot file roi thoat — nhat ky lan boot 14/08 ghi dung
  # "ELAN1203 present, nothing to do". Workaround tu vo hieu khi khong con can.
  # Bo di thi xoa file nay va dong import trong configuration.nix.
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
