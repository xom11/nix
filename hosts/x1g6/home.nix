{ pkgs, ... }:
{
  # BAN MAU cho may NixOS ke tiep. Chiec x1g6 that da ban (09/08/2026); host
  # nay giu lai lam diem xuat phat, nen bo module o day duoc dung theo macmini
  # va airm3 — tuc nhung gi thuc su dang chay hang ngay — chu khong phai theo
  # thoi diem chiec laptop con o day.
  #
  # Bo o macOS ma KHONG mang sang duoc, va vi sao:
  #   dotfiles.macos.{hammerspoon,sleepwatcher}  API rieng cua macOS
  #   programs.beckon-serve                      chay bang launchd agent; tren
  #                                              Linux beckon duoc goi thang tu
  #                                              binding cua WM (i3 conf.d /
  #                                              dconf GNOME / sway config)
  #   dotfiles.browser.dotbrave                  bang [pwa] ghi managed policy
  #                                              cua macOS
  #   pkgs.tongue                                overlay khong cung cap
  #                                              aarch64-linux (da kiem)
  imports = [
    ../../home-manager
  ];
  modules.home-manager = {
    base = {
      nixos.enable = true;
    };
    dotfiles = {
      ai.enable = true;
      terminal.kitty.enable = true;
      browser.firefox.enable = true;
      vscode.enable = true;
      conda.enable = true;
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
      # Doi ung cua brew casks tren macmini: kitty, brave, vscode, telegram,
      # vlc, localsend, nemo, bitwarden. Truoc day KHONG host NixOS nao bat,
      # nen `kitty` khong duoc cai — trong khi nixos/base dat xdg.terminal-exec
      # mac dinh la kitty.desktop VA i3 conf.d/launch-app.conf bind
      # $mod+Return -> kitty. Do bang closure 09/08/2026: kitty = 0.
      nixos.enable = true;
    };
    programs = {
      agenix.enable = true;
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
  home.packages = [
    pkgs.beckon
    pkgs.bws
  ];
}
