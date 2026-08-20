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
          # Without the Qt module every Qt app loses input entirely, including
          # `fcitx5-lotus-settings`. There is no top-level `fcitx5-qt` attr.
          # Qt6 only on purpose: the Qt5 variant drags in a whole Qt5 closure for
          # apps this host does not have, so diagnose still complains about Qt5.
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
      # The only field that matters here is `Mode`: the addon's built-in default
      # is `Preedit`, one of the two modes that underline. It takes a DISPLAY
      # NAME ("Uinput (Smooth)"), while `ModeOrder` below takes short names --
      # a different namespace, and `Mode=Smooth` is silently pushed to `Preedit`.
      #
      # Shared by all three i18n hosts (desktop, rog, vm) but only rog enables
      # `modules.nixos.services.fcitx5-lotus`, which provides the server and udev
      # rules. The other two get Uinput mode with no server; consequences unmeasured.
      # Fix that with a host-specific rule rather than by editing this file.
      ".config/fcitx5/conf/lotus.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/fcitx5.d/lotus.conf";
      };
      # A SEPARATE file, not part of lotus.conf -- miss it and the rules vanish
      # silently.
      #
      # Messenger (Chromium PWA) drops characters because its composer cannot
      # keep up with injected BackSpace. All modes were measured: no mode is both
      # clean and free of underlining. `Slow` is the deliberate choice -- accept
      # dropped characters to avoid underlining. Set the code to 5 for `Preedit`
      # to reverse that. Slowing down further does not close the race, and
      # `FixUinputWithAck` does not fix it either (tried, failed).
      #
      # Two silent traps: `Mode` here is a NUMERIC CODE, unlike the global `Mode`
      # which is a display name; and fcitx5 does not validate it, so 99 is
      # accepted and saved. Reading it back proves storage, not validity.
      #
      # The app id is per-PWA, so messenger.com in an ordinary Brave tab is NOT
      # covered -- covering it would slow the whole browser.
      ".config/fcitx5/conf/lotus-app-rules.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/fcitx5.d/lotus-app-rules.conf";
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
