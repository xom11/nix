{input, config, pkgs, lib, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  system-manager.allowAnyDistro = true;
  environment.etc."profile.d/system-manager-path.sh".enable = false
}