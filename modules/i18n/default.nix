{pkgs, ...}:{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-bamboo
        fcitx5-gtk
      ];
      waylandFrontend = true; 
    };
  };
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
}