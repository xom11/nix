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
    github-copilot-cli
    gemini-cli
    mkpasswd
    opencode
    yq-go

    hugo
  ];
}
