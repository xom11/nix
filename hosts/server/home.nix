{ pkgs, device, ... }:
{
  imports = [
    ../../home-manager
    ../../profiles/core.nix
  ];
  home.shellAliases = {
    update = ''
      git -C ~/.nix pull
      nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake ~/.nix#${device}
    '';
  };
  home.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
  };
  modules.home-manager = {
    programs = {
      # Opting out of core. Both look accidental rather than deliberate -- this
      # is a box reached only over ssh, and programs.ssh is what installs
      # authorized_keys. Flip to true once you have confirmed you want them.
      btop.enable = false;
      ssh.enable = false;
    };
    services = {
      # syncthing.enable = true;
    };
  };
}
