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
  # Am thanh la thu MOI host co DE deu can, khong rieng i3wm. Truoc day khoi nay
  # nam trong i3wm.nix, nen tren rog no den tu module GNOME chu khong tu day —
  # do duoc: ep rog xuong `types = ["sway"]` thi ca pipewire lan rtkit deu false.
  # Nghia la ngay nao GNOME roi rog, hai phien sway/hyprland mat tieng ma khong
  # co gi bao.
  #
  # `alsa.support32Bit` CO Y khong nam o day, xem i3wm.nix.
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
