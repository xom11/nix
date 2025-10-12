
{lib, config, dotfileDir, pkgs, ...}:
let
  cfg = config.modules.dotfiles.karabiner;
  rules_dir = "${dotfileDir}/karabiner/rules";
in
{
  options.modules.dotfiles.karabiner = {
    enable = lib.mkEnableOption "Enable karabiner dotfiles";
  };
  config = lib.mkIf cfg.enable {
    home.activation = {
      karabiner = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p $HOME/.config/karabiner
        ${pkgs.yq-go}/bin/yq eval ${dotfileDir}/karabiner/karabiner.yml -o=json > $HOME/.config/karabiner/karabiner.json
        ${pkgs.yq-go}/bin/yq eval '
          .profiles[].complex_modifications.rules += 
            load("'${rules_dir}'/modifier_keys.yml") +
            load("'${rules_dir}'/tab_navigation.yml") +
            load("'${rules_dir}'/home_row.yml") +
            load("'${rules_dir}'/audio_brightness.yml") +
            load("'${rules_dir}'/clipboard_number.yml") +
            load("'${rules_dir}'/tab_shortcuts.yml") +
            load("'${rules_dir}'/other.yml") +
            []
          ' ${dotfileDir}/karabiner/main.yml -o=json > $HOME/.config/karabiner/karabiner.json
        /opt/homebrew/bin/karabiner_cli --select-profile "Default profile"
      '';
    };
  };
}
