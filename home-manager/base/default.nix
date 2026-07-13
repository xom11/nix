{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = if pkgs.stdenv.isDarwin then "Brave\ Browser" else "brave";
    TERMINAL = "kitty";
    SHELL = "${pkgs.zsh}/bin/zsh";
    NIX_CONFIG="extra-experimental-features = nix-command flakes";
    NIXPKGS_ALLOW_UNFREE = 1;
  };
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.activation = {
    # Every dotfiles module symlinks out-of-store into ~/.nix, so on a fresh
    # machine the working tree has to land before linkGeneration runs —
    # otherwise the first switch leaves a home full of dangling symlinks.
    gitclonenix = lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
      if [ ! -d "${config.home.homeDirectory}/.nix" ]; then
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/xom11/nix.git \
          "${config.home.homeDirectory}/.nix" -q --depth 1
      fi
    '';
  };
}
