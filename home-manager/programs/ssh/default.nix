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

    };

    age.secrets.ssh-config = {
      file = ./age.d/config.age;
      path = "${config.home.homeDirectory}/.ssh/config.d/config";
    };

    home.file = {
      ".ssh/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config";
      };
    };
  }
