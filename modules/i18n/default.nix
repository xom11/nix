{pkgs, ...}:{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-bamboo
        kdePackages.fcitx5-unikey
        libsForQt5.fcitx5-unikey
        fcitx5-gtk
        fcitx5-mozc
      ];
      waylandFrontend = true; 
    };
  };
  home.packages = with pkgs; [
    gnomeExtensions.kimpanel
  ];
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
}