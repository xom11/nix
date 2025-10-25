
{lib,config, dotfileDir, pkgs, ...}:
let
  cfg = config.modules.dotfiles.aerospace;
  scripts = builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./scripts) );
  wallpaperPath = "${dotfileDir}/images/studio-ghibli-sunny-hut-4k.jpg";
in
{
  options.modules.dotfiles.aerospace = {
    enable = lib.mkEnableOption "Enable aerospace dotfiles";
  };
  config = lib.mkIf cfg.enable{
    home.file = {
      ".aerospace.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/aerospace/aerospace.toml";
      };
    };
    home.packages = builtins.map (name:
      pkgs.writeShellScriptBin name (builtins.readFile (./scripts + "/${name}"))
    ) scripts;
    home.activation = {
      setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        /usr/bin/osascript -e 'tell application "System Events" to set picture of every desktop to POSIX file "${wallpaperPath}"'
      '';
    };
  };
}
