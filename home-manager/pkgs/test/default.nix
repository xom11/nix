{
  pkgs,
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  home.packages = with pkgs; [
    aichat
    caligula
    codex
    gemini-cli
    mkpasswd
    opencode
    yq-go
  ];
}
