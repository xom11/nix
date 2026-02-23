{...}: {
  imports = [
    ../../nix-darwin
  ];
  modules.nix-darwin = {
    brew.enable = true;
    launchd = {
      kanata.enable = true;
    };
  };
  homebrew = {
    brews = [
    ];
    casks = [
    ];
  };
}
