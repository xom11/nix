{pkgs, lib, config, ...}:
let 
  cfg = config.modules.i18n;
in
{
  options.modules.i18n ={
    enable = lib.mkEnableOption "Enable i18n settings";
  };
  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          # fcitx5-bamboo
          fcitx5-gtk
          fcitx5-unikey
        ];
        waylandFrontend = true; 
        settings = {
          inputMethod = {
            GroupOrder."0" = "Default";
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "bamboo";
            };
            "Groups/0/Items/0".Name = "keyboard-us";
            "Groups/0/Items/1".Name = "unikey";
          };
          globalOptions = {
            Hotkey = {
            };
          };
        };
      };
    };
  };
}
