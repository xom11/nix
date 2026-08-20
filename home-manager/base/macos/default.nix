{
  config,
  homeDir,
  repoPath,
  mkModule,
  device,
  ...
}:
mkModule config ./. {
  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#${device}";
  };

  # The Homebrew formula HARDCODES `~/.config/beckon/apps.toml` in its service
  # definition, so this link is the only way to point it at the repo's real file.
  #
  # Both machines used to do this by hand and drifted: one had a correct symlink,
  # the other a stale COPY, so its beckon registered an old keymap with no warning.
  #
  # mkOutOfStoreSymlink, NOT `source = ...`: a path literal copies into the store
  # and links to a READ-ONLY copy, which breaks two things -- edits stop applying
  # until the next switch, and beckon 0.8.0+ WRITES BACK to this file from its
  # Settings window, which would fail against the store.
  home.file."${config.xdg.configHome}/beckon/apps.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${repoPath}/configs/shortcuts/apps.shared.toml";
}
