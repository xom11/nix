{pkgs, ...}: {
  imports = [
    ../../home-manager
  ];
  home.sessionVariables = {
    # LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
  };
  modules.home-manager = {
    # Carries the `update` + `system-manager-update` aliases plus the nix
    # PATH / XDG_DATA_DIRS wiring.
    base = {
      ubuntu.enable = true;
    };
    dotfiles = {
      ai.enable = true;
      terminal.kitty.enable = true;
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
    services = {
      # syncthing.enable = true;
    };
  };
  home.packages = [
    pkgs.discordchatexporter-cli
    # pkgs.kanata
  ];
}
