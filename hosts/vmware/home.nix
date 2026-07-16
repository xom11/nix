{pkgs, ...}: {
  imports = [
    ../../home-manager
  ];
  modules.home-manager = {
    base = {
      nixos.enable = true;
    };
    dotfiles = {
      terminal.kitty.enable = true;
      # browser.qutebrowser.enable = true;
      rofi.enable = true;
      # vscode.enable = true;
    };
    environments = {
      fonts.enable = true;
      i3wm.enable = true;
      i18n.enable = true;
    };
    pkgs = {
      dev.enable = true;
      lang.enable = true;
      tools.enable = true;
    };
    programs = {
      btop.enable = true;
      # git.enable = true;
      herdr.enable = true;
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
