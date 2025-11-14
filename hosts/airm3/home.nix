{ pkgs, device, ... }:
{
  imports = [
    ../../home-manager
  ];
  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#${device}";
  };
  home.packages = [
    pkgs.bws
  ];
  modules = {
    fonts.enable = true;
    dotfiles = {
      btop.enable = true;
      kitty.enable = true;
      # qutebrowser.enable = true;
      vscode.enable = true;
      ssh.enable = true;
      yazi.enable = true;
      conda.enable = true;
      # karabiner.enable = true;
      sleepwatcher.enable = true;
      # aerospace.enable = true;
      hammerspoon.enable = true;
      zsh.enable = true;
      tmux.enable = true;
    };
    pkgs = {
      cli.enable = true;
      dev.enable = true;
    };
    programs = {
      git.enable = true;
      bin.enable = true;
      nvim.enable = true;
    };
    services = {
      syncthing.enable = true;
    };
    secrets.enable = true;
  };
}
