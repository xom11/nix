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
          fcitx5-gtk
          # Thieu module Qt thi `fcitx5-diagnose` bao "Cannot find fcitx5 input
          # method module for Qt5/Qt6" va moi app Qt mat han bo go — ke ca
          # `fcitx5-lotus-settings` (Qt6). Do duoc tren rog 16/08/2026.
          # KHONG lien quan toi chuyen gach chan trong kitty: kitty khong phai
          # app Qt, no noi thang zwp_text_input_v3. Day la loi thu hai, rieng.
          #
          # KHONG co attr top-level `fcitx5-qt`; phai di qua qt6Packages
          # (kdePackages.fcitx5-qt tra ve CUNG store path). Co y chi lay Qt6:
          # libsForQt5.fcitx5-qt keo them ca closure Qt5 cho nhung app host nay
          # gan nhu khong co. Doi lai, diagnose se van than phien ve Qt5 —
          # do la danh doi, khong phai thieu sot.
          qt6Packages.fcitx5-qt
          fcitx5-lotus
        ];
        waylandFrontend = true;
        # Do not use settings so that fcitx5 UI can manage its own config
        # Config will be saved directly at ~/.config/fcitx5/
      };
    };
    home.file = {
      # dotfile
      ".config/fcitx5/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/fcitx5.d/config";
      };
      ".config/fcitx5/profile" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/fcitx5.d/profile";
      };
      # X11 (i3wm)
      ".xprofile".text = ''
        export XMODIFIERS="@im=fcitx"
        export GTK_IM_MODULE=fcitx
        export QT_IM_MODULE=fcitx
        export SDL_IM_MODULE=fcitx
        export GLFW_IM_MODULE=ibus
      '';
    };
    # Wayland (sway) — sessionVariables are set via systemd user environment
    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      SDL_IM_MODULE = "fcitx";
    };
  }
