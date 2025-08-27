{config, pkgs, lib, ...}:
{
  
  home.activation = {

    copyAuthorizedKeys = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf ~/.ssh/authorized_keys;
      mkdir -p ~/.ssh;
      cp ${./authorized_keys} ~/.ssh/authorized_keys;
      chmod 600 ~/.ssh/authorized_keys;
    '';

    # genSshKeyGen = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #   if [ ! -f ~/.ssh/id_ed25519 ]; then
    #     /usr/bin/ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
    #   fi
    # '';
  };
}