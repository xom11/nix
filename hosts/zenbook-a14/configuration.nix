{
  lib,
  config,
  ...
}: {
  imports = [
    ../../system-manager
  ];
  modules.system-manager.services.kanata.enable = true;
}
