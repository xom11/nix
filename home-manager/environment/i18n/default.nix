{pkgs, lib, device, ...}:
lib.mkIf (device == "x1g6"|| device == "desktop") 
{
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
      settings.inputMethod = {
        GroupOrder."0" = "Default";
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "bamboo";
        };
        "Groups/0/Items/0".Name = "keyboard-us";
        "Groups/0/Items/1".Name = "unikey";
      };
    };
  };
  home.packages = with pkgs; [
  ];
}
