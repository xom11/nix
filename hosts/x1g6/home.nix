{ pkgs, ... }:
{
  imports = [
    ../../home-manager
    ../../profiles/core.nix
    ../../profiles/linux-gui.nix
  ];
  modules.home-manager = {
    base = {
      nixos.enable = true;
    };
    dotfiles = {
      # browser.qutebrowser.enable = true;
      vscode.enable = true;
    };
    environments = {
      i3wm.enable = true;
    };
  };
  home.packages = [
    pkgs.raiseorlaunch
  ];
}
