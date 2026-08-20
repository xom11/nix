{ pkgs, ... }:
{
  # The ELAN1203 (I2C-HID) touchpad failed to probe on the first boot after
  # install with `can't add hid device: -22` (-EINVAL: the driver read the HID
  # descriptor before the device was ready). No input device is created, so the
  # symptom looks exactly like "the desktop does not see the touchpad" and leads
  # you to search libinput, where there is nothing to find.
  #
  # Re-measured: the next ordinary boot probed fine, so the failure was probably a
  # side effect of that install's kexec and warm reboot rather than a real fault.
  #
  # Kept anyway, because one clean boot proves nothing about a timing race. The
  # loop checks /proc/bus/input/devices BEFORE touching modprobe, so on healthy
  # hardware it greps one file and exits -- the workaround disables itself.
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
