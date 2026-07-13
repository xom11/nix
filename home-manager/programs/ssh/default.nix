{
  lib,
  config,
  getPath,
  pkgs,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
  agenixEnabled = config.modules.home-manager.services.agenix.enable;
in
  mkModule config ./. {
    home.activation = {
      # Merge, never overwrite. This used to `rm -rf` the file on every switch,
      # which silently dropped any key added out of band -- on a box reached
      # only over ssh, that locks you out. Revoking a key is a manual edit.
      copyAuthorizedKeys = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p ~/.ssh && chmod 700 ~/.ssh
        [ -L ~/.ssh/authorized_keys ] && rm -f ~/.ssh/authorized_keys
        touch ~/.ssh/authorized_keys
        while IFS= read -r key; do
          case "$key" in "" | "#"*) continue ;; esac
          grep -qxF "$key" ~/.ssh/authorized_keys || printf '%s\n' "$key" >> ~/.ssh/authorized_keys
        done < ${./authorized_keys}
        chmod 600 ~/.ssh/authorized_keys
      '';

      genSshKeyGen = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ! -f ~/.ssh/id_ed25519 ]; then
          ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
        fi
      '';
    };

    age.secrets = lib.mkIf agenixEnabled {
      ssh-config = {
        file = ./age.d/config.age;
        path = "${config.home.homeDirectory}/.ssh/age.d/config";
      };
    };

    home.file = {
      ".ssh/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config";
      };
    };
  }
