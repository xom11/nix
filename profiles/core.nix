# The toolkit every real host gets. Enabled with mkDefault, so a host that
# genuinely does not want a piece opts out visibly:
#
#   modules.home-manager.programs.git.enable = false;
#
# Kept out of home-manager/ on purpose: everything under there is auto-imported
# into every host, which would make this unconditional rather than opt-in.
{lib, ...}: let
  on = lib.mkDefault true;
in {
  modules.home-manager = {
    programs = {
      btop.enable = on;
      git.enable = on;
      herdr.enable = on;
      nvim.enable = on;
      ssh.enable = on;
      tmux.enable = on;
      yazi.enable = on;
      zsh.enable = on;
    };
    pkgs = {
      dev.enable = on;
      lang.enable = on;
      tools.enable = on;
    };
  };
}
