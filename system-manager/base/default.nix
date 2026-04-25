{
  config,
  pkgs,
  lib,
  system,
  ...
}: {
  nixpkgs.hostPlatform = system;
  system-manager.allowAnyDistro = true;
  system-manager.preActivationAssertions = {
    setup_init = {
      enable = true;
      script = ''
        sudo usermod -aG sudo $USER
      '';
    };
  };
  environment.etc."sudoers.d/nix-path" = {
    text = ''
      Defaults secure_path="/run/system-manager/sw/bin:/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
    '';
  };
  environment.systemPackages = with pkgs; [
    cowsay
  ];
}
