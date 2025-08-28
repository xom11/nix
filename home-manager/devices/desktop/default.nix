{ pkgs, device, lib, ... }:
lib.mkIf (device == "desktop") {
  home.shellAliases = {
    update = ''
      git -C ~nix pull
      nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake ~/.nix#desktop
    '';
    galaxy-update = ''
      ansible-galaxy install -r  ~/.nix/ansible/requirements.yml
    '';
    ansible-update = ''
      ansible-playbook -i ~/.nix/ansible/hosts ~/.nix/ansible/ubuntu.yml
    '';
  };

  # show desktop apps
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;
  home.file.".config/environment.d/nix-path.conf".text = ''
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