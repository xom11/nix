{ pkgs, device, ... }:
{
  nixpkgs.overlays = [
    (import ../../overlays)
  ];
  imports = [
    ../../home-manager
  ];
  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#${device}";
  };
  home.packages = [
    pkgs.bws
  ];
  modules.home-manager = {
    environment = {
      fonts.enable = true;
    };
    dotfiles = {
      # aerospace.enable = true;
      conda.enable = true;
      hammerspoon.enable = true;
      # karabiner.enable = true;
      kitty.enable = true;
      # qutebrowser.enable = true;
      secrets.enable = true;
      sleepwatcher.enable = true;
      vscode.enable = true;
    };
    pkgs = {
      test.enable = true;
      dev.enable = true;
    };
    programs = {
      bin.enable = true;
      btop.enable = true;
      git.enable = true;
      nvim.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      yazi.enable = true;
      zsh.enable = true;
    };
    services = {
      # syncthing.enable = true;
    };
  };
}
