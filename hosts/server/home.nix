{ pkgs, ... }:
{
  imports = [
    ../../home-manager
    ../../profiles/core.nix
  ];
  home.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
  };
  modules.home-manager = {
    # Carries the `update` alias (was hand-copied here) plus the nix PATH /
    # XDG_DATA_DIRS wiring for a systemd user session.
    base = {
      ubuntu.enable = true;
    };
    programs = {
      # Opting out of core. Not obviously deliberate, but left off -- unlike
      # ssh, nothing depends on it.
      btop.enable = false;
    };
    services = {
      # syncthing.enable = true;
    };
  };
}
