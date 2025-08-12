{input, config, pkgs, lib, distro, username, user,  sudo_user,  ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  system-manager.allowAnyDistro = true;
  environment.etc."environment.d/system-manager-path.conf".text= ''
    PATH="/run/system-manager/sw/bin/:$PATH"
  '';
  environment.etc."sysctl.conf".text = lib.mkIf (distro == "ubuntu") ''
    kernel.apparmor_restrict_unprivileged_userns=0
  '';
  environment.etc."sudoers.d/nopasswd".text = ''
    ${username} ALL=(ALL) NOPASSWD: ALL
  '';
  system-manager.preActivationAssertions = {
    # zsh = {
    #   enable = true;
    #   script = ''
    #     sudo chsh -s $(which zsh) $USER
    #   '';
    # }; 
    echo123 = {
      enable = true;
      script = ''
        echo ${username} ${user} ${sudo_user} 
      '';
    };
  };
}