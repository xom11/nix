{ lib, config, pkgs, ... }:
let
  scripts = builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./.) );
  cfg = config.modules.programs.bin;
in
{
  options.modules.programs.bin = {
    enable = lib.mkEnableOption "Enable bin program";
  };
  config = lib.mkIf cfg.enable {
    home.packages = builtins.map (name:
      pkgs.writeShellScriptBin name (builtins.readFile (./. + "/${name}"))
    ) scripts;
  };
}