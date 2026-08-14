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

    # Phan chung cua audio (pipewire, rtkit, pulseaudio=false) da chuyen sang
    # common.nix — moi host co DE deu can.
    #
    # RIENG support32Bit thi O LAI, va day la quyet dinh chu khong phai sot: no
    # KHONG phai no-op tren x86_64. Dua no sang common.nix (guard `cfg.enable`)
    # se keo mot closure pipewire i686 len rog, thu khong ai yeu cau. De o day thi
    # x1g6 giu nguyen nhu cu con rog/vm giu nguyen nhu cu — khong host nao doi
    # hanh vi. (Ban chat no la ve app 32-bit chu khong ve i3; muon dung cho, cho
    # do la hosts/x1g6/configuration.nix, de lan khac.)
    services.pipewire.alsa.support32Bit = true;
    # nature scrolling
    services.libinput.touchpad = {
      # accelProfile = "flat";
      naturalScrolling = true;
      accelSpeed = "0.8";
    };
  };
}
