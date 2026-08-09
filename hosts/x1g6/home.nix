{ pkgs, ... }:
{
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
      vscode.enable = true;
      rofi.enable = true;
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
      git.enable = true;
      herdr.enable = true;
      nvim.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      yazi.enable = true;
      zsh.enable = true;
    };
  };
  # raiseorlaunch da bo (09/08/2026). Hong ca hai duong: overlay cu ghim fork
  # khanhkhanhlele/raiseorlaunch — repo lan tai khoan deu 404 nen KHONG BUILD
  # duoc, chan ca `nixos-rebuild` cua host nay; con ban 2.3.5 trong nixpkgs thi
  # build duoc nhung CHAY LA CHET (`from distutils import spawn`, ma python 3.12
  # da bo distutils). Khong config nao goi no ca: i3 conf.d/launch-app.conf dung
  # ~/.config/i3/scripts/i3-focus.sh, va `beckon` da duoc kiem la chay tren i3.
  home.packages = [ ];
}
