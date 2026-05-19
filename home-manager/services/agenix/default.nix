{
  config,
  pkgs,
  system,
  agenix,
  mkModule,
  ...
}: let
  publicKeys = import ./keys.nix;
  recipients = pkgs.writeText "agenix-recipients" (
    builtins.concatStringsSep "\n" publicKeys + "\n"
  );

  identityPath = "${config.home.homeDirectory}/.ssh/id_ed25519";
  secretsNix = "${config.home.homeDirectory}/.nix/home-manager/services/agenix/secrets.nix";
in
  mkModule config ./. {
    home.packages = [
      pkgs.age
      agenix.packages.${system}.default
    ];

    age.identityPaths = [identityPath];

    # Plain-text artefacts for the nvim transparent-edit plugin
    home.file.".config/agenix/recipients".source = recipients;
    home.file.".config/agenix/identity".text = identityPath + "\n";

    # Lets `agenix` CLI locate the rules file from any CWD
    home.sessionVariables.RULES = secretsNix;
  }
