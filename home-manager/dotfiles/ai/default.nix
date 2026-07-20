{
  config,
  lib,
  mkModule,
  ...
}:
  mkModule config ./. {
    modules.home-manager.dotfiles.ai = {
      # "aichat.d".enable = lib.mkDefault true;
      "claude.d".enable = lib.mkDefault true;
      "codex.d".enable = lib.mkDefault true;
      # "gemini.d".enable = lib.mkDefault true;
      "opencode.d".enable = lib.mkDefault true;
      "pi.d".enable = lib.mkDefault true;
    };
  }
