{
  config,
  pkgs,
  mkModule,
  getPath,
  ...
}: let
  pwd = getPath ./.;
  aichatDir =
    if pkgs.stdenv.hostPlatform.isLinux
    then ".config/aichat"
    else "Library/Application Support/aichat";
in
  mkModule config ./. {
    home.file = {
      # claude
      ".claude/commands" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/claude.d/commands";
      };
      ".claude/CLAUDE.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/claude.d/CLAUDE.md";
      };

      # aichat
      "${aichatDir}/roles" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/aichat.d/roles";
      };

      # gemini
      ".gemini/GEMINI.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/gemini.d/GEMINI.md";
      };
    };
  }
