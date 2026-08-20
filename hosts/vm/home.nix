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
      # GNOME instead of i3wm, to test the shortcuts on the GNOME path. A CHOICE,
      # not a constraint: `types` is a list, so a host can enable several desktops.
      # i3wm.enable = true;
      gnome.enable = true;
      i18n.enable = true;
    };
    pkgs = {
      dev.enable = true;
      lang.enable = true;
      tools.enable = true;
      # The Linux desktop apps. No NixOS host used to enable this, so kitty was
      # never installed even though nixos/base points xdg.terminal-exec at it.
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
    # The mac hosts get beckon and tongue; Linux gets beckon only, since the
    # tongue overlay provides no aarch64-linux build.
    pkgs.beckon
    pkgs.bws
  ];
}
