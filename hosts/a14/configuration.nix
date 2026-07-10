{...}: {
  imports = [
    ../../system-manager
  ];
  modules.system-manager = {
    services = {
      tailscale.enable = true;
    };
  };
}
