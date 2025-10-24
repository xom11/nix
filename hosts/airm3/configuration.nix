{...}:
{
  imports = [
    ../../nix-darwin
  ];
  modules = {
    brew.enable = true;
    launchd = {
      kanata.enable = true;
    };
  };
}