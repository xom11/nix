{
  pkgs,
  config,  
  mkModule,
  ...
}:

mkModule config ./. {
  home.packages = with pkgs; [
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
  ];
}
