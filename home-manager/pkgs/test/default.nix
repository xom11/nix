{
  pkgs,
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  home.packages = with pkgs; [
    caligula
    discordchatexporter-cli
    github-copilot-cli
    mkpasswd
    yq-go

    hugo
  ];
}
