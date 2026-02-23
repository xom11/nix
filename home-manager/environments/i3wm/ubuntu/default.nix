{
  mkModule,
  config,
  ...
}:
mkModule config ./. {
  home.file = {
    # 96, 120, 144, 192 -> scale 1x, 1.25x, 1.5x, 2x
    # ".Xresources".text = ''
    #     Xft.dpi: 144
    #   '';

    # fcitx5
    ".xprofile".text =''
      export XMODIFIERS="@im=fcitx"
      export GTK_IM_MODULE=fcitx
      export QT_IM_MODULE=fcitx
      export SDL_IM_MODULE=fcitx
      export GLFW_IM_MODULE=ibus
    '';
  };
}
