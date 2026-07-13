{pkgs, ...}: {
  imports = [
    ../../home-manager
    ../../profiles/core.nix
  ];
  home.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
  };
  modules.home-manager = {
    base = {
      ubuntu.enable = true;
    };
    dotfiles = {
      ai.enable = true;
    };
    services = {
      # syncthing.enable = true;
    };
  };
  home.packages = [
    pkgs.discordchatexporter-cli
    pkgs.micromamba
  ];
}
