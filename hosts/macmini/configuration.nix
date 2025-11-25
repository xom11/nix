{
  lib,
  config,
  ...
}: {
  imports = [
    ../../nix-darwin
  ];
  modules.nix-darwin = {
    brew.enable = true;
    launchd = {
      kanata.enable = true;
    };
  };

  # Enable darwin-specific settings
  # power.sleep = {
  #   computer = "never";
  # };
}

