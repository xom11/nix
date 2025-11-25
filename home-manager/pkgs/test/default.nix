{
  pkgs,
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  home.packages = with pkgs; [
    caligula
    gemini-cli
    mkpasswd
    yq-go
    codex
    opencode
  ];
}
