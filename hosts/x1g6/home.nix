{ pkgs, ... }:
{
  imports = [
    ../../home-manager
    ../../profiles/core.nix
    ../../profiles/linux-gui.nix
  ];
  home.shellAliases = {
    update = ''
      git -C ~nix pull
      sudo nixos-rebuild switch --impure --refresh --flake ~/.nix#x1g6
    '';
  };
  modules.home-manager = {
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
