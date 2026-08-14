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
  config = lib.mkIf (cfg.enable && builtins.elem "i3wm" cfg.types) {
    services.xserver.enable = true;
    services.xserver.windowManager.i3.enable = true;
    # services.xserver.dpi = 144;

    services.pulseaudio.enable = false; # Use Pipewire, the modern sound subsystem
    security.rtkit.enable = true; # Enable RealtimeKit for audio purposes
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    # nature scrolling
    services.libinput.touchpad = {
      # accelProfile = "flat";
      naturalScrolling = true;
      accelSpeed = "0.8";
    };
  };
}
