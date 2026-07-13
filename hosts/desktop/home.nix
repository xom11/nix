{pkgs, ...}: {
  imports = [
    ../../home-manager
    ../../profiles/core.nix
    ../../profiles/linux-gui.nix
  ];
  home.sessionVariables = {
    # LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
  };
  modules.home-manager = {
    # Carries the `update` + `system-manager-update` aliases (both were
    # hand-copied here) plus the nix PATH / XDG_DATA_DIRS wiring.
    base = {
      ubuntu.enable = true;
    };
    dotfiles = {
      ai.enable = true;
    };
    environments = {
      i3wm.enable = true;
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
