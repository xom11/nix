
{lib, config, dotfileDir, pkgs, ...}:
let
  cfg = config.modules.dotfiles.karabiner;
in
{
  options.modules.dotfiles.karabiner = {
    enable = lib.mkEnableOption "Enable karabiner dotfiles";
  };
  config = lib.mkIf cfg.enable {
    # home.file = {
    #   ".config/karabiner/karabiner.json" = {
    #     source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/karabiner/karabiner.json";
    #   };
    home.activation = {
      karabiner = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/.config/karabiner
        ${pkgs.yq-go}/bin/yq eval ${dotfileDir}/karabiner/karabiner.yml -o=json > $HOME/.config/karabiner/karabiner.json
        /opt/homebrew/bin/karabiner_cli --select-profile "Default profile"
      '';
    };
  };
}
