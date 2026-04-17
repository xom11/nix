{
  lib,
  config,
  getPath,
  pkgs,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.activation = {
      copyAuthorizedKeys = lib.hm.dag.entryAfter ["writeBoundary"] ''
        rm -rf ~/.ssh/authorized_keys;
        mkdir -p ~/.ssh;
        cp ${./authorized_keys} ~/.ssh/authorized_keys;
        chmod 600 ~/.ssh/authorized_keys;
      '';

      genSshKeyGen = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ! -f ~/.ssh/id_ed25519 ]; then
          ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
        fi
      '';

      decryptSshConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p ~/.ssh/config.d
        for f in "${pwd}"/age.d/*.age; do
          if [ -f "$f" ]; then
            name=$(basename "$f" .age)
            age -d -i ~/.ssh/id_ed25519 "$f" > ~/.ssh/config.d/"$name" 2>/dev/null || true
            if [ ! -s ~/.ssh/config.d/"$name" ]; then
              rm -f ~/.ssh/config.d/"$name"
            fi
          fi
        done
      '';

    home.file = {
      ".ssh/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config";
      };
    };
  }
