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
    DOTFILE_DIR = "${dotfileDir}";
    NIX_CONFIG="extra-experimental-features = nix-command flakes";
    NIXPKGS_ALLOW_UNFREE = 1;
  };
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # home.activation = {
  #   gitclonenix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #     if [ ! -d ~/.nix ]; then
  #       ${pkgs.git}/bin/git clone https://github.com/kln-os/nix.git ~/.nix -q --depth 1
  #     else
  #       ${pkgs.git}/bin/git -C ~/.nix pull -q
  #     fi
  #   '';
  # };

}
