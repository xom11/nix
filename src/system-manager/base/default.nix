{input, config, pkgs, lib, distro,  ... }:
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
    $USER ALL=(ALL) NOPASSWD: ALL
  '';
  system-manager.preActivationAssertions = {
    hello = {
      enable = true;
      script = ''
        sudo echo "Hello from system-manager!"
      '';
    }; 
  };
}