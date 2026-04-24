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
  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = if pkgs.stdenv.isDarwin then "open -a Vivaldi" else "vivaldi-stable";
    TERMINAL = "kitty";
    SHELL = "${pkgs.zsh}/bin/zsh";
    NIX_CONFIG="extra-experimental-features = nix-command flakes";
    NIXPKGS_ALLOW_UNFREE = 1;
  };
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.activation = {
    gitclonenix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d ~/.nix ]; then
        ${pkgs.git}/bin/git clone https://github.com/xom11/nix.git ~/.nix -q --depth 1
      # else
      #   ${pkgs.git}/bin/git -C ~/.nix pull -q
      fi
    '';
  };
}
