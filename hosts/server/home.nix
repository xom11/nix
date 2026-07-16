{ pkgs, ... }:
{
  imports = [
    ../../home-manager
  ];
  home.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
  };
  modules.home-manager = {
    # Carries the `update` alias plus the nix PATH / XDG_DATA_DIRS wiring
    # for a systemd user session.
    base = {
      ubuntu.enable = true;
    };
    pkgs = {
      dev.enable = true;
      lang.enable = true;
      tools.enable = true;
    };
    programs = {
      # btop deliberately off; ssh installs authorized_keys and ~/.ssh/config,
      # which this box (reached only over ssh) depends on.
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
}
