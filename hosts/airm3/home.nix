{pkgs, ...}: {
  imports = [
    ../../home-manager
    ../../profiles/core.nix
    ../../profiles/macos.nix
  ];
  home.packages = [
    pkgs.bws
    pkgs.beckon
  ];
  modules.home-manager = {
    dotfiles = {
      ai.enable = true;
      browser = {
        firefox.enable = true;
      };
    };
    services = {
      # syncthing.enable = true;
    };
  };
}
