{pkgs, ...}: {
  imports = [
    ../../home-manager
  ];
  modules.home-manager = {
    base = {
      ubuntu.enable = true;
    };
    dotfiles = {
      ai.enable = true;
      terminal = {
        kitty.enable = true;
      };
      browser = {
        dotbrowser.vivaldi.enable = true;
      };
      rofi.enable = true;
    };
    environments = {
      fonts.enable = true;
      # i3wm.enable = true;
      gnome.enable = true;
      sway.enable = true;
      sway.ubuntu.enable = true;
      i18n.enable = true;
    };
    pkgs = {
      test.enable = true;
      dev.enable = true;
      ubuntu.enable = true;
    };
    programs = {
      btop.enable = true;
      git.enable = true;
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
  ];
}
