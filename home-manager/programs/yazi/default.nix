
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.programs.yazi;
in
{
  options.modules.programs.yazi = {
    enable = lib.mkEnableOption "Enable yazi configuration";
  };
  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      settings = {
        manager = {
          ratio = [
            1
            4
            3
          ];
          sort_by = "natural";
          sort_sensitive = true;
          sort_reverse = false;
          sort_dir_first = true;
          linemode = "none";
          show_hidden = true;
          show_symlink = true;
        };
      };
    };
  };
}
