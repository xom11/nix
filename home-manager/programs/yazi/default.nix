{lib, pkgs, config, getPath, ... }:
let
  cfg = config.modules.programs.yazi;
  pwd = getPath  ./.;
in
{
  options.modules.programs.yazi = {
    enable = lib.mkEnableOption "Enable yazi dotfiles";
  };
  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/yazi" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/yazi.d";
      };
    };
    home.packages = [
      pkgs.yazi
      pkgs.yaziPlugins.smart-enter
    ];
  };
}
