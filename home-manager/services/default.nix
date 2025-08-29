{ pkgs, lib, device, ... }:

lib.mkMerge [
  {
    # services.ssh-agent.enable = true;
    # services.podman.enable = true;
  }

  (lib.mkIf (device == "x1g6" || device == "desktop") {
  })

  # (lib.mkIf (device == "x1g6") {
  #   services.picom.enable = true;
  # })
]