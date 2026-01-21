{
  mkModule,
  config,
  ...
}:
mkModule config ./. {
  home.file = {
    # 96, 144, 192 -> scale 1x, 1.5x, 2x
    ".Xresources" = {
      text = ''
        Xft.dpi: 144
      '';
    };
  };
}
