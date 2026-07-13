{pkgs, ...}: {
  imports = [
    ../../home-manager
    ../../profiles/core.nix
    ../../profiles/linux-gui.nix
  ];
  modules.home-manager = {
    base = {
      ubuntu.enable = true;
    };
    dotfiles = {
      ai.enable = true;
      browser = {
      };
    };
    environments = {
      # i3wm.enable = true;
      gnome.enable = true;
      sway.enable = true;
      sway.ubuntu.enable = true;
    };
    pkgs = {
      ubuntu.enable = true;
    };
    services = {
      # syncthing.enable = true;
    };
  };
  home.packages = [
    pkgs.discordchatexporter-cli
  ];
}
