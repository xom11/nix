{lib, pkgs, config, dotfileDir, ... }:
let
  cfg = config.modules.dotfiles.yazi;
in
{
  options.modules.dotfiles.yazi = {
    enable = lib.mkEnableOption "Enable yazi dotfiles";
  };
  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/yazi/yazi.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/yazi/yazi.toml";
      };
      ".config/yazi/theme.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/yazi/theme.toml";
      };
      ".config/yazi/keymap.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/yazi/keymap.toml";
      };
    };
    home.packages = [
      pkgs.yazi
      pkgs.yaziPlugins.smart-enter
    ];
  };
}
