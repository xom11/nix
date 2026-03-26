{
  config,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      # Vault template configuration
      # Copy these to your vault's .obsidian/ folder when creating new vaults
      # Note: obsidian.json is NOT managed by Nix because it contains device-specific vault paths
      "${config.xdg.configHome}/obsidian/vault-template" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/obsidian.d";
      };
    };
  }
