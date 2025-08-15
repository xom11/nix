
{ pkgs,... }:
let 
  username = builtins.getEnv "USER"; 
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11"; 

imports = builtins.map (name: ../../src/home-manager/${name}) [
  "gui/environment"
  "gui/dotfiles"
  "gui/fonts"

  "cli/services"
  "cli/programs"
  "cli/pkgs"
  "cli/os/ubuntu"
];
  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "kitty";
  };

  home.shellAliases = {
    update = ''
      git -C ~nix pull
      nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake ~/.nix#desktop
      '';
    galaxy-update = ''
      sudo $(which ansible-galaxy) install -r  ~/.nix/src/ansible/requirements.yml
      '';
    ansible-update = ''
      sudo $(which ansible-playbook) -i ~/.nix/src/ansible/hosts ~/.nix/src/ansible/ubuntu.yml
      '';
  }; 

  # show desktop apps
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;
  home.file.".config/environment.d/nix-path.conf".text= ''
      PATH="$HOME/.nix-profile/bin:$PATH"
    '';

  # system manager path
  programs.zsh.initContent = ''
      # source system manager path
      if [ -d /run/system-manager/sw/bin ]; then
        export PATH="/run/system-manager/sw/bin/:$PATH"
      fi
    '';
    
}

