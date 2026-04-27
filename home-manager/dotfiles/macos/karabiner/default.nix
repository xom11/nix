{
  lib,
  config,
  pkgs,
  getPath,
  mkModule,
  ...
}: let
  cfg = config.modules.dotfiles.karabiner;
  pwd = getPath ./.;
  rules_dir = "${pwd}/rules";
in
  mkModule config ./. {
    home.activation = {
      karabiner = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p $HOME/.config/karabiner
        ${pkgs.yq-go}/bin/yq eval ${pwd}/karabiner.yml -o=json > $HOME/.config/karabiner/karabiner.json
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
          ' ${pwd}/main.yml -o=json > $HOME/.config/karabiner/karabiner.json
        /opt/homebrew/bin/karabiner_cli --select-profile "Default profile"
      '';
    };
  }
