{ nixos-hardware, ... }:
{
  # No G531GT profile in nixos-hardware, only the common modules.
  # `common-cpu-intel` pulls in `common-gpu-intel` for the UHD 630.
  imports = [
    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-ssd
    ../../nixos
    ./disko.nix
    ./hardware.nix
    ./nvidia.nix
    ./touchpad.nix
  ];

  # `time.hardwareClockInLocalTime` went with Windows (2026-08-14): it only
  # existed to keep two OSes in agreement.

  # Overrides nixos/base's mkDefault "24.11" -- installed fresh on 26.05, so
  # there is no old state to preserve.
  system.stateVersion = "26.05";

  # Native Wayland for Chromium/Electron. Not a performance tweak -- it fixes
  # beckon's hotkeys for Brave PWAs. Under XWayland every PWA window reports the
  # browser's own class, so beckon cannot see a running instance and opens a
  # duplicate on each press. The distinguishing WM_CLASS instance half exists but
  # Hyprland never exposes it. Under native Wayland the class is the .desktop
  # file stem, which beckon already targets, so the problem disappears rather
  # than being worked around.
  #
  # Safe here because the nixpkgs wrapper only adds the flag when WAYLAND_DISPLAY
  # is set, and rog has no X11 session at all.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  modules.nixos.services = {
    environments = {
      enable = true;
      # GNOME dropped 2026-08-19 along with GDM. It was the safety net for a
      # broken sway/hyprland/niri config; the remaining exits are TTY and SSH,
      # which depend on neither GPU nor compositor.
      #
      # The two axes are separate now (see environments/default.nix): `types`
      # picks which sessions exist, `displayManager` picks the login screen. So
      # dropping "gnome" here no longer costs the login screen.
      #
      # niri's nixpkgs module sets `defaultSession = "niri"` and niri.nix must
      # override that -- it decides ReGreet's preselected entry.
      types = ["sway" "hyprland" "niri"];

      # greetd (headless daemon) + ReGreet (the UI, inside cage).
      displayManager = "regreet";
    };
    # dotbrave left the rebuild path entirely (2026-08-16, see ATTIC.md).
    # brave.toml and the binary remain; it is applied by hand.
    kanata.enable = true;
    # udev rule + server unit for the IME's Uinput modes, the ones that do not
    # underline in kitty. Pairs with `linux-dev-names-exclude` in
    # configs/kanata/defcfg.kbd, or kanata grabs lotus's virtual device.
    fcitx5-lotus.enable = true;
    # The only host with libvirtd: it has VT-x and the disk for it.
    libvirtd.enable = true;
  };
}
