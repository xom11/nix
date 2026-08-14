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
  # nam trong i3wm.nix, nen host nao khong chay i3 thi khong duoc khai gi ca.
  #
  # DA DO LAI 14/08/2026, va ket qua BAC BO lap luan dau tien o day:
  #   - `services.pipewire.*` gan nhu la no-op tren moi host hien co. nixpkgs
  #     `programs.sway` va `programs.hyprland` deu import `wayland-session.nix`,
  #     file do bat `services.graphical-desktop`, va module do da dat
  #     `services.pipewire` san. Nen "bo GNOME di la sway/hyprland mat tieng"
  #     -- ly do cu ghi o day -- LA SAI.
  #   - Thu that su doi hanh vi la `security.rtkit.enable`: graphical-desktop
  #     KHONG dat no, chi module GNOME dat (mkDefault). Thieu dong do thi phien
  #     sway/hyprland tren host khong co GNOME chay pipewire ma khong co
  #     realtime priority, va no im lang.
  #
  # Vi sao ban ghi cu sai: phep do chay o Task 2, TRUOC khi sway.nix ton tai.
  # Luc do `types = ["sway"]` khong khop module nao, nen no do "khong co desktop
  # nao ca" chu khong phai "sway thieu GNOME".
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
