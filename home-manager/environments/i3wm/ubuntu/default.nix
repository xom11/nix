{
  mkModule,
  config,
  ...
}:
mkModule config ./. {
  home.file = {
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
