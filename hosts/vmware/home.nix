{
  pkgs,
  device,
  ...
}: {
  imports = [
    ../../home-manager
  ];
  home.shellAliases = {
    update = ''
      git -C ~nix pull
      sudo nixos-rebuild switch --impure --refresh --flake ~/.nix${device}
    '';
  };
  modules.home-manager = {
    environments = {
      i18n.enable = true;
      fonts.enable = true;
      x11.enable = true;
    };
    dotfiles = {
      i3.enable = true;
      kitty.enable = true;
      # qutebrowser.enable = true;
      rofi.enable = true;
      # vscode.enable = true;
    };
    pkgs = {
      test.enable = true;
      dev.enable = true;
      gui.enable = true;
    };
    programs = {
      bin.enable = true;
      btop.enable = true;
      git.enable = true;
      nixvim.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      yazi.enable = true;
      zsh.enable = true;
    };
    secrets.enable = true;
  };
  home.packages = [
  ];
}

