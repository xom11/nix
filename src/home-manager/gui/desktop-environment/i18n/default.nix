{pkgs, ...}:{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-bamboo
        # kdePackages.fcitx5-unikey
        # libsForQt5.fcitx5-unikey
        libsForQt5.fcitx5-with-addons
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
        "Groups/0/Items/1".Name = "bamboo";
      };
    };
  };
  home.packages = with pkgs; [
  ];
}
