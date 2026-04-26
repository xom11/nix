{pkgs, ...}: {
  nixpkgs.overlays = [
    (import ../../overlays)
  ];
  imports = [
    ../../home-manager
  ];
  home.packages = [
    pkgs.bws
  ];
  modules.home-manager = {
    base = {
      macos.enable = true;
    };
    environments = {
      fonts.enable = true;
    };
    dotfiles = {
      # aerospace.enable = true;
      ai.enable = true;
      conda.enable = true;
      hammerspoon.enable = true;
      # karabiner.enable = true;
      kitty.enable = true;
      # qutebrowser.enable = true;

      sleepwatcher.enable = true;
      vscode.enable = true;
      firefox.enable = true;
    };
    pkgs = {
      test.enable = true;
      dev.enable = true;
    };
    programs = {
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
