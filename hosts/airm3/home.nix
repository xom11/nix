{pkgs, ...}: {
  nixpkgs.overlays = [
    (import ../../overlays)
  ];
  imports = [
    ../../home-manager
  ];
  home.packages = [
    pkgs.bws
    pkgs.beckon
  ];
  modules.home-manager = {
    base = {
      macos.enable = true;
    };
    environments = {
      fonts.enable = true;
    };
    dotfiles = {
      macos = {
        hammerspoon.enable = true;
        sleepwatcher.enable = true;
      };
      terminal = {
        kitty.enable = true;
      };
      browser = {
        firefox.enable = true;
      };
      ai.enable = true;
      conda.enable = true;
      vscode.enable = true;
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
