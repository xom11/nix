{ pkgs, device, lib, ... }:
lib.mkIf (device == "macmini") {
  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#macmini";
  };
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
    };
    pkgs = {
      cli.enable = true;
      dev.enable = true;
    };
    programs = {
      git.enable = true;
      nvim.enable = true;
      tmux.enable = true;
      zsh.enable = true;
      ssh.enable = true;
    };
    secrets.enable = true;
  };
}