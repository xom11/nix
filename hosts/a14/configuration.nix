{...}: {
  imports = [
    ../../system-manager
  ];
  modules.system-manager = {
    services = {
      kanata.enable = true;
      openssh.enable = true;
    };
  };
  # Zenbook A14 (Snapdragon X Plus) — suspend buggy trên ARM, lid switch ignore
  # để tránh sleep khi gập màn. Idle 15 phút → shutdown thay vì sleep.
  environment.etc = {
    "systemd/logind.conf.d/90-lid-switch-ignore.conf".text = ''
      [Login]
      HandleLidSwitch=ignore
      HandleLidSwitchExternalPower=ignore
      HandleLidSwitchDocked=ignore
    '';
    "systemd/logind.conf.d/91-auto-shutdown.conf".text = ''
      [Login]
      IdleAction=poweroff
      IdleActionSec=15min
    '';
  };
}
