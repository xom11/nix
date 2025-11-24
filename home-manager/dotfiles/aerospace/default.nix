
{lib,config, getPath, ...}:
let
  cfg = config.modules.dotfiles.aerospace;
  scripts = builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./scripts) );
  pwd = getPath  ./.;
in
{
  options.modules.dotfiles.aerospace = {
    enable = lib.mkEnableOption "Enable aerospace dotfiles";
  };
  config = lib.mkIf cfg.enable{
    home.file = {
      ".aerospace.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/aerospace.toml";
      };
    };
    # home.packages = builtins.map (name:
    #   pkgs.writeShellScriptBin name (builtins.readFile (./scripts + "/${name}"))
    # ) scripts;
  };
}
