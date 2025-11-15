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
      git -C ~nix pull
      nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake ~/.nix#${device}
    '';
    galaxy-update = ''
      ansible-galaxy install -r  ${cfgDir}/ansible.requirements.yml
    '';
    ansible-update = ''
      ansible-playbook -i "localhost," ${cfgDir}/ansible.yml
    '';
  };
  modules = {
    dotfiles = {
      btop.enable = true;
      yazi.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };
    pkgs = {
      cli.enable = true;
      dev.enable = true;
    };
    programs = {
      nvim.enable = true;
      bin.enable = true;
      git.enable = true;
    };
    services = {
      syncthing.enable = true;
    };
  };
  home.packages = [
    pkgs.discordchatexporter-cli
  ];
}
