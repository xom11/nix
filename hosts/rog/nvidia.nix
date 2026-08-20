{ config, lib, ... }:
{
  # ASUS ROG Strix G531GT -- Optimus.
  #
  # This machine's HDMI port hangs off NVIDIA, not Intel, and the LG UltraFine
  # is the only monitor in use (hyprland.lua disables eDP-1). So `prime.offload`
  # below does NOT mean "Intel drives the display" -- it only covers the
  # built-in panel, which nothing turns on any more.
  #
  # Bus IDs read from /sys/bus/pci/devices on this machine, not guessed. A wrong
  # one means a black screen with no error pointing at the cause.
  services.xserver.videoDrivers = [ "nvidia" ];

  # The two blocks below are one half of a system whose other half is
  # `hl.env("AQ_DRM_DEVICES", ...)` in hyprland.lua; either alone is useless.

  # This does NOT load nvidia sooner -- measured, systemd-modules-load still
  # finishes around 10 s, same as when udev did it. What it buys is an ORDERING
  # constraint, which is stronger than winning a race on time:
  #   systemd-modules-load.service -> sysinit.target -> basic.target -> greetd
  # insmod is synchronous, so the card is ready before greetd starts. Under udev
  # the load was asynchronous with no relation to the display manager, and that
  # race is what made Hyprland pick the wrong GPU.
  # `boot.initrd.kernelModules` is the heavier option, kept in reserve for when
  # DRM has to be up even earlier (plymouth).
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  # Stable names with no colon in them.
  # Not `/dev/dri/card0`: the minor number is an accident of load order, and the
  # block above changes load order. Not `/dev/dri/by-path/...`: AQ_DRM_DEVICES
  # and WLR_DRM_DEVICES both split on `:`, which by-path names already contain.
  # Symlinks are safe -- both consumers canonicalize before comparing.
  #
  # Both node types are needed because the compositors differ: Hyprland and sway
  # want the card node, niri wants the render node (`debug { render-drm-device }`),
  # and renderD128/129 are as arbitrary as the card minors.
  #
  # `intel-card` exists because listing only NVIDIA makes Hyprland lose sight of
  # eDP-1, turning the `disabled = true` line in hyprland.lua into a dead line --
  # the laptop panel stayed on showing a text console.
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", KERNEL=="card[0-9]*", SUBSYSTEMS=="pci", KERNELS=="0000:01:00.0", SYMLINK+="dri/nvidia-card"
    SUBSYSTEM=="drm", KERNEL=="renderD[0-9]*", SUBSYSTEMS=="pci", KERNELS=="0000:01:00.0", SYMLINK+="dri/nvidia-render"
    SUBSYSTEM=="drm", KERNEL=="card[0-9]*", SUBSYSTEMS=="pci", KERNELS=="0000:00:02.0", SYMLINK+="dri/intel-card"
  '';

  # The sway (wlroots) counterpart of AQ_DRM_DEVICES. Unlike Hyprland it cannot
  # be set from the config: sway's `exec` only affects children, and by then the
  # DRM backend has already chosen a GPU. Only wlroots reads this -- mutter
  # ignores it, aquamarine reads its own, and niri has no env for it at all.
  environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/nvidia-card";

  # Again for the greeter, because the line above does not reach it:
  # `sessionVariables` goes through PAM and /etc/profile, both on the user login
  # path, while greetd is a system service that runs before anyone logs in.
  # It matters -- ReGreet runs inside cage, which is also wlroots, so without
  # this the login screen picks the GPU by `boot_vga` (Intel) and lands on the
  # laptop panel. mkIf so this does not emit an empty greetd unit on GDM hosts.
  systemd.services.greetd = lib.mkIf config.services.greetd.enable {
    environment.WLR_DRM_DEVICES = "/dev/dri/nvidia-card";
  };

  hardware.nvidia = {
    modesetting.enable = true;

    # Without it the machine wakes from sleep with the GPU in a broken state.
    powerManagement.enable = true;

    # Off on purpose: finegrained saves real battery but is still flaky on
    # Turing, and it fails on wake rather than at boot, which is hard to
    # attribute. Revisit once the machine is otherwise stable.
    powerManagement.finegrained = false;

    # TU117 is Turing so the open module would work, but the closed one is the
    # better-trodden path for this generation.
    open = false;

    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      # offload, not sync: `sync` keeps NVIDIA running continuously and is the
      # configuration most likely to blank the display on a machine with no MUX.
      offload = {
        enable = true;
        enableOffloadCmd = true; # provides `nvidia-offload`
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
