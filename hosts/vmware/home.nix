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
      sudo nixos-rebuild switch --impure --refresh --flake ~/.nix#${device}
    '';
  };
  modules.home-manager = {
    environments = {
      i18n.enable = true;
      fonts.enable = true;
      i3wm.enable = true;
    };
    dotfiles = {
      terminal.kitty.enable = true;
      # browser.qutebrowser.enable = true;
      rofi.enable = true;
      # vscode.enable = true;
    };
    pkgs = {
      dev.enable = true;
      lang.enable = true;
      tools.enable = true;
    };
    programs = {
      btop.enable = true;
      # git.enable = true;
      nvim.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      yazi.enable = true;
      zsh.enable = true;
    };

  };
  home.packages = [
  ];
}

