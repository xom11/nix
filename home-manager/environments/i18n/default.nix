{
  pkgs,
  config,
  mkModule,
  getPath,
  ...
}: let
  pwd = getPath ./.;
in
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
        # Do not use settings so that fcitx5 UI can manage its own config
        # Config will be saved directly at ~/.config/fcitx5/
      };
    };
    home.file = {
      # dotfile
      ".config/fcitx5" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/fcitx5.d";
      };
      # ubuntu
      ".xprofile".text = ''
        export XMODIFIERS="@im=fcitx"
        export GTK_IM_MODULE=fcitx
        export QT_IM_MODULE=fcitx
        export SDL_IM_MODULE=fcitx
        export GLFW_IM_MODULE=ibus
      '';
    };
  }
