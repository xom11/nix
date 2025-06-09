
{input, config, pkgs, lib, username, ... }:
let
  bamboo = pkgs.callPackage ./ibus-bamboo.nix {};
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/configuration.nix
      ../share
    ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = [
      bamboo
    ];
  };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = username;
  nixpkgs.config.allowUnfree = true;

  services.flatpak.enable = true;

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 7d";
  };

  security.sudo.wheelNeedsPassword = false;

  # Enable hardware virtualization support.
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
  virtualisation.libvirtd.enable = true;
  users.users.${username}.extraGroups = [ "libvirtd" ];
  
  hardware.bluetooth.enable = true;
  # Audio
  #
  hardware.pulseaudio.enable = false; # Use Pipewire, the modern sound subsystem

  security.rtkit.enable = true; # Enable RealtimeKit for audio purposes

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Uncomment the following line if you want to use JACK applications
    # jack.enable = true;
  };
}