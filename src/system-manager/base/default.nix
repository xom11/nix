{input, config, pkgs, lib, distro, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  system-manager.allowAnyDistro = true;
  environment.etc."environment.d/system-manager-path.conf".text= ''
    PATH="/run/system-manager/sw/bin/:$PATH"
  '';
  environment.etc."sysctl.conf".text = lib.mkIf (distro == "ubuntu") ''
    kernel.apparmor_restrict_unprivileged_userns=0
  '';
  system-manager.preActivationAssertions = {

    setup_init = {
      enable = true;
      script = ''
        sudo usermod -aG sudo $USER
        chsh -s $(which zsh)
        '';
    };
  };
}