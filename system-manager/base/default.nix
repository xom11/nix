{
  input,
  config,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.hostPlatform = "aarch64-linux";
  system-manager.allowAnyDistro = true;
  system-manager.preActivationAssertions = {
    setup_init = {
      enable = true;
      script = ''
        sudo usermod -aG sudo $USER
      '';
    };
  };
  environment.systemPackages = with pkgs; [
    cowsay
  ];
}
