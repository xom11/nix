{
  config,
  lib,
  getRelPath,
  ...
}: let
  relPath = getRelPath ./.;
  pathList = ["modules"] ++ (lib.splitString "/" relPath);
  cfg = lib.getAttrFromPath pathList config;
in {
  # Audio belongs to every host with a desktop, not just i3wm, where this used to
  # live.
  #
  # Re-measured, and it REFUTED the original reasoning here: `services.pipewire.*`
  # is nearly a no-op, because nixpkgs' sway and hyprland modules both import
  # wayland-session.nix, which enables graphical-desktop, which already sets
  # pipewire. The line that actually changes behaviour is `security.rtkit.enable`,
  # which graphical-desktop does NOT set -- only the GNOME module does. Without it
  # a sway/hyprland session on a GNOME-less host runs pipewire with no realtime
  # priority, silently.
  #
  # The old note was wrong because it was measured before sway.nix existed, when
  # `types = ["sway"]` matched no module at all -- so it measured "no desktop",
  # not "sway without GNOME".
  #
  # `alsa.support32Bit` left with i3wm.nix and is deliberately NOT here: on x86_64
  # it is not a no-op and would pull an i686 pipewire closure onto every desktop
  # host. Set it in a host's own configuration.nix if 32-bit apps are needed.
  config = lib.mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
}
