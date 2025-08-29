{lib, config, dotfileDir, ... }:
let
  cfg = config.modules.dotfiles.run-or-raise;
in
{
  options.modules.dotfiles.run-or-raise = {
    enable = lib.mkEnableOption "Enable run-or-raise dotfiles";
  };
  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/run-or-raise/shortcuts.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/run-or-raise/shortcuts.conf";
      };
    };
  };
}
