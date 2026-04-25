{
  lib,
  config,
  ...
}: {
  imports = [
    ../../system-manager
  ];
  modules.system-manager.services.kanata.enable = true;
  modules.system-manager.services.tailscale.enable = true;
}
