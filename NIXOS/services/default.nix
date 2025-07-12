{pkgs, username, ...}:
{
  virtualisation.docker.enable = true;
  users.users.${username}.extraGroups = [ "docker" ];

  # virtualisation.vmware.host.enable = true;

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ username ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ username ];


  services.tailscale.enable = true;
  services.openssh.enable = true;
  services.preload.enable = true;
  services.flatpak.enable = true;

  services.pulseaudio.enable = false; # Use Pipewire, the modern sound subsystem
  security.rtkit.enable = true; # Enable RealtimeKit for audio purposes
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(hyper, esc)";
          };
          otherlayer = {};
        };
        extraConfig = ''
          [hyper:C-M-A]
        '';
      };
    };
  };
# Optional, but makes sure that when you type the make palm rejection work with keyd
# https://github.com/rvaiya/keyd/issues/723
environment.etc."libinput/local-overrides.quirks".text = ''
  [Serial Keyboards]
  MatchUdevType=keyboard
  MatchName=keyd virtual keyboard
  AttrKeyboardIntegration=internal
'';
}