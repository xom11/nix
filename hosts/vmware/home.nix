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
    environment = {
      i18n.enable = true;
      fonts.enable = true;
      x11.enable = true;
    };
    dotfiles = {
      btop.enable = true;
      i3.enable = true;
      kitty.enable = true;
      # qutebrowser.enable = true;
      rofi.enable = true;
      ssh.enable = true;
      vscode.enable = true;
      yazi.enable = true;
    };
    pkgs = {
      cli.enable = true;
      dev.enable = true;
      gui.enable = true;
    };
    programs = {
      bin.enable = true;
      git.enable = true;
      nvim.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };
    secrets.enable = true;
  };
  home.packages = [
  ];
}

