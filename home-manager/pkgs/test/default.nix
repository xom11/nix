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
    discordchatexporter-cli
    github-copilot-cli
    gemini-cli
    mkpasswd
    opencode
    yq-go

    hugo
  ];
}
