{lib, config, dotfileDir, pkgs, ... }:
let
  cfg = config.modules.dotfiles.i3;
  scripts = builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./scripts) );
in
{
  options.modules.dotfiles.i3 = {
    enable = lib.mkEnableOption "Enable i3 dotfiles";
  };
  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/i3/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/i3/config";
      };
    };
    home.packages = builtins.map (name:
      pkgs.writeShellScriptBin name (builtins.readFile (./scripts + "/${name}"))
    ) scripts;
  };
}
