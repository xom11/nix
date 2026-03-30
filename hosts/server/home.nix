{ pkgs, device, ... }:
let
  cfgDir = "~/.nix/hosts/${device}";
in
{
  imports = [
    ../../home-manager
  ];
  home.shellAliases = {
    update = ''
      git -C ~/.nix pull
      nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake ~/.nix#${device}
    '';
    galaxy-update = ''
      ansible-galaxy install -r  ${cfgDir}/ansible/requirements.yml
    '';
    ansible-update = ''
      ansible-playbook -i "localhost," ${cfgDir}/ansible/main.yml
    '';
  };
  home.sessionVariables = {
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
  };
  modules.home-manager = {
    dotfiles = {
      claude.enable = true;
    };
    environments = {
    };
    pkgs = {
      test.enable = true;
      dev.enable = true;
    };
    programs = {
      bin.enable = true;
      btop.enable = true;
      git.enable = true;
      nixvim.enable = true;
      ssh.enable = true;
      sesh.enable = true;
      tmux.enable = true;
      yazi.enable = true;
      zsh.enable = true;
    };
    services = {
      # syncthing.enable = true;
    };
  };
  home.packages = [
    pkgs.discordchatexporter-cli
    pkgs.micromamba
  ];
}
