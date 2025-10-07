{input, config, pkgs, lib, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  system-manager.allowAnyDistro = true;
  environment.etc."environment.d/system-manager-path.conf".text= ''
    PATH="/run/system-manager/sw/bin/:$PATH"
  '';
  system-manager.preActivationAssertions = {
    setup_init = {
      enable = true;
      script = ''
        sudo usermod -aG sudo $USER
        '';
    };
  };
}
