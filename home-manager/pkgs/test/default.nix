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
    claude-code
    codex
    gemini-cli
    mkpasswd
    opencode
    yq-go
  ];
}
