{
  pkgs,
  lib,
  username,
  dotfileDir,
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
    BROWSER = "brave";
    TERMINAL = "kitty";
    SHELL = "${pkgs.zsh}/bin/zsh";
    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
    DOTFILE_DIR = "${dotfileDir}";
    NIX_CONFIG="extra-experimental-features = nix-command flakes";
    NIXPKGS_ALLOW_UNFREE = 1;
  };
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.activation = {
    gitclonenix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d ~/.nix ]; then
        git clone https://github.com/kln-os/nix.git ~/.nix -q --depth 1
      fi
    '';
  };

}
