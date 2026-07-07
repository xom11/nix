{
  pkgs,
  ...
}: {
  imports = [
    ../../home-manager
  ];
  modules.home-manager = {
    base.enable = true;
    programs.zsh.enable = true;
    pkgs.dev.enable = false;
    pkgs.gui.enable = false;
  };
}