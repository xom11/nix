{
  config,
  dotfileDir,
  pkgs,
  lib,
  ...
}:

lib.mkIf pkgs.stdenv.isLinux {
  home.packages = with pkgs; [
    galculator
    waybar
    dunst
    libnotify
  ];
  home.file = {
    ".config/sway/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/sway/config";
    };
    ".config/sway/run_or_raise.sh" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/sway/run_or_raise.sh";
    };
  };
}