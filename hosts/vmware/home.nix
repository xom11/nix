{
  pkgs,
  device,
  ...
}: {
  imports = [
    ../../home-manager
    ../../profiles/core.nix
    ../../profiles/linux-gui.nix
  ];
  home.shellAliases = {
    update = ''
      git -C ~nix pull
      sudo nixos-rebuild switch --impure --refresh --flake ~/.nix#${device}
    '';
  };
  modules.home-manager = {
    programs = {
      # Opting out of core -- was already commented out before profiles existed.
      git.enable = false;
    };
    dotfiles = {
      # browser.qutebrowser.enable = true;
      # vscode.enable = true;
    };
    environments = {
      i3wm.enable = true;
    };
  };
  home.packages = [
  ];
}
