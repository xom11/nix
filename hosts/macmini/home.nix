{ pkgs, device, ...}:
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
    pkgs.fcitx5-macos
  ];
  modules.home-manager = {
    environment = {
      fonts.enable = true;
    };
    dotfiles = {
      kitty.enable = true;
      # qutebrowser.enable = true;
      vscode.enable = true;
      conda.enable = true;
      # karabiner.enable = true;
      sleepwatcher.enable = true;
      # aerospace.enable = true;
      hammerspoon.enable = true;
      secrets.enable = true;
    };
    pkgs = {
      test.enable = true;
      dev.enable = true;
    };
    programs = {
      yazi.enable = true;
      btop.enable = true;
      git.enable = true;
      bin.enable = true;
      nvim.enable = true;
      zsh.enable = true;
      tmux.enable = true;
      ssh.enable = true;
    };
    services = {
      # syncthing.enable = true;
    };
  };
}
