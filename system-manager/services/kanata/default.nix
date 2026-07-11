{
  config,
  pkgs,
  mkModule,
  ...
}: let
  # Baked into the store, not read from ${repoPath}: the service runs under a
  # DynamicUser with ProtectHome=true, and /home/kln is 0750, so it cannot reach
  # the working tree. The whole configs/kanata dir is copied so the relative
  # (include "defcfg.kbd" / "main.kbd") in kanata_ubuntu.kbd resolve in the store.
  # Editing a .kbd therefore needs a `system-manager switch`, not just a restart.
  kanataConfig = ../../../configs/kanata;
in
  mkModule config ./. {
    # /dev/uinput -> group input so the DynamicUser can create the virtual
    # keyboard (/dev/input/event* is already root:input). static_node makes the
    # node appear even though uinput is built into the a14 kernel (no udev event).
    environment.etc."udev/rules.d/99-kanata-uinput.rules".text = ''
      KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
    '';
    # no-op when uinput is builtin; loads it on kernels where it is a module
    environment.etc."modules-load.d/kanata-uinput.conf".text = "uinput\n";

    environment.systemPackages = [pkgs.kanata];

    systemd.services.kanata = {
      enable = true;
      description = "kanata keyboard remapper";
      documentation = ["https://github.com/jtroo/kanata"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "notify";
        ExecStart = "${pkgs.kanata}/bin/kanata --cfg ${kanataConfig}/kanata_ubuntu.kbd";
        Restart = "no";

        # Unprivileged and isolated — kln never joins the input group; only this
        # ephemeral service user does. Mirrors the nixpkgs services.kanata module.
        DynamicUser = true;
        SupplementaryGroups = ["input"];

        # hardening
        DeviceAllow = ["/dev/uinput rw" "char-input r"];
        DevicePolicy = "closed";
        CapabilityBoundingSet = [""];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateNetwork = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = ["AF_UNIX"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = ["native"];
        SystemCallFilter = ["@system-service" "~@privileged" "~@resources"];
        UMask = "0077";
      };
    };
  }
