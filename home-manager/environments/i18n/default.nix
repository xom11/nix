{
  pkgs,
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  # nixos
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        # fcitx5-bamboo
        fcitx5-gtk
        # fcitx5-unikey
        qt6Packages.fcitx5-unikey
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
  # ubuntu
  home.file = {
    ".xprofile".text = ''
      export XMODIFIERS="@im=fcitx"
      export GTK_IM_MODULE=fcitx
      export QT_IM_MODULE=fcitx
      export SDL_IM_MODULE=fcitx
      export GLFW_IM_MODULE=ibus
    '';
  };
}
