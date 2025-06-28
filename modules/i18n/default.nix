{pkgs, ...}:{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-bamboo
        # kdePackages.fcitx5-unikey
        # libsForQt5.fcitx5-unikey
      ];
      waylandFrontend = true; 
    };
  };
  home.packages = with pkgs; [
  ];
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    GLFW_IM_MODULE = "ibus";
  };
}