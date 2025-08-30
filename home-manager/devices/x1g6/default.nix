{ pkgs, device, lib, ... }:
lib.mkIf (device == "x1g6") 
{
  home.shellAliases = {
    update = ''
      git -C ~nix pull
      sudo nixos-rebuild switch --impure --refresh --flake ~/.nix#x1g6
    '';
  };
  modules = {
    i18n.enable = true;
    fonts.enable = true;
    x11.enable = true;
    dotfiles = {
      btop.enable = true;
      i3.enable = true;
      kitty.enable = true;
      qutebrowser.enable = true;
      vscode.enable = true;
      rofi.enable = true;
      ssh.enable = true;
      yazi.enable = true;
    };
    pkgs = {
      cli.enable = true;
      gui.enable = true;
      dev.enable = true;
    };
    programs = {
      nvim.enable = true;
      git.enable = true;
      tmux.enable = true;
      zsh.enable = true;
      ssh.enable = true;
    };
    secrets.enable = true;
    sources = {
      raiseorlaunch.enable = true;
    };
  };
  home.packages = [
  ];
}