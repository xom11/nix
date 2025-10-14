{config, lib, ...}:
let
  cfg = config.services.desktop-environment;
in
{
  config = lib.mkIf (cfg.enable && cfg.type == "i3wm") {
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
