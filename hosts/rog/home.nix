{pkgs, ...}: let
in {
  imports = [
    ../../home-manager
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
    environments = {
    };
    pkgs = {
      test.enable = true;
      dev.enable = true;
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
    pkgs.micromamba
  ];
}
