{ pkgs, lib, ... }:
{
  imports = [
    ../../home-manager
  ];
  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#macmini";
  };
  home.packages = [
    pkgs.bws
  ];
  modules = {
    fonts.enable = true;
    dotfiles = {
      btop.enable = true;
      kitty.enable = true;
      qutebrowser.enable = true;
      vscode.enable = true;
      ssh.enable = true;
      yazi.enable = true;
      conda.enable = true;
      # kanata.enable = true;
      karabiner.enable = true;
    };
    pkgs = {
      cli.enable = true;
      dev.enable = true;
    };
    programs = {
      git.enable = true;
      bin.enable = true;
      nvim.enable = true;
      tmux.enable = true;
      zsh.enable = true;
      ssh.enable = true;
    };
    secrets.enable = true;
  };
}
