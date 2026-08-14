{pkgs, ...}: {
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
      rofi.enable = true;
    };
    environments = {
      fonts.enable = true;
      # GNOME thay i3wm de test configs/shortcuts/apps.linux.toml tren duong
      # GNOME. Day la LUA CHON, khong phai rang buoc: tu nhanh nay,
      # modules.nixos.services.environments.types la list, mot host duoc bat
      # nhieu desktop cung luc (xem rog).
      # i3wm.enable = true;
      gnome.enable = true;
      i18n.enable = true;
    };
    pkgs = {
      dev.enable = true;
      lang.enable = true;
      tools.enable = true;
      # Bo ung dung desktop cua Linux: kitty, brave, vscode, telegram, vlc...
      # Truoc day KHONG host NixOS nao bat cai nay, nen `kitty` khong duoc cai
      # du nixos/base dat xdg.terminal-exec mac dinh la kitty.desktop va
      # i3 conf.d/launch-app.conf binding $mod+Return -> kitty.
      nixos.enable = true;
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
  home.packages = [
    # macmini/airm3 co ca beckon + tongue; tren Linux chi co beckon --
    # overlay tongue khong cung cap aarch64-linux.
    pkgs.beckon
    pkgs.bws
  ];
}
