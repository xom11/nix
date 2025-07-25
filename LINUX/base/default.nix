{input, config, pkgs, lib, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  system-manager.allowAnyDistro = true;
  environment.etc."environment.d/system-manager-path.conf".text= ''
    PATH="/run/system-manager/sw/bin/:$PATH"
  '';
  environment.etc = {
    "profile.d/system-manager-path.sh".enable = false
  }
}