{
  pkgs,
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  home.packages = with pkgs; [
    caligula
    codex
    gemini-cli
    mkpasswd
    opencode
    yq-go
  ];
}
