{
  config,
  lib,
  mkModule,
  pkgs,
  getPath,
  repoPath,
  ...
}: let
  pwd = getPath ./.;
  lazygitConfigDir =
    if pkgs.stdenv.isDarwin
    then "Library/Application Support/lazygit"
    else ".config/lazygit";
in
  mkModule config ./. {
    home.file = {
      ".config/git/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/git.d/config";
      };
      ".config/gh-dash/config.yml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/gh-dash.d/config.yml";
      };
      "${lazygitConfigDir}/config.yml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/lazygit.d/config.yml";
      };
    };
    home.packages = with pkgs; [
      git
      gh-dash
      delta
      lazygit
      diffnav
      gitleaks
    ];

    # Installs the pre-push fence on every machine that switches.
    #
    # The path must be ABSOLUTE: git resolves `core.hooksPath` against the CWD, not
    # the repo root, so a relative one silently runs no hook when pushing from a
    # subdirectory.
    #
    # Wired into activation rather than documented as a manual step -- this repo
    # already has a precedent for a fence that was present but not blocking.
    home.activation.gitHooksPath = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -d "${repoPath}/.git" ] && [ -x "${repoPath}/.githooks/pre-push" ]; then
        ${pkgs.git}/bin/git -C "${repoPath}" config core.hooksPath "${repoPath}/.githooks"
      fi
    '';
  }
