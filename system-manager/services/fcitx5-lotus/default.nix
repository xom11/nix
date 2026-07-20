{config, lib, pkgs, username, fcitx5-lotus-pkg, ...}:
with lib;
let
  cfg = config.modules.system-manager.services.fcitx5-lotus;
in {
  options.modules.system-manager.services.fcitx5-lotus.enable =
    mkEnableOption "Fcitx5 Lotus system service";

  config = mkIf cfg.enable {
    environment.etc."modules-load.d/fcitx5-lotus-uinput.conf".text = "uinput\n";

    environment.etc."udev/rules.d/99-fcitx5-lotus-uinput.rules".text = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", MODE="0660", GROUP="input"
    '';

    environment.systemPackages = [fcitx5-lotus-pkg];

    users.users.uinput_proxy = {
      isSystemUser = true;
      group = "input";
      description = "Lotus Uinput Proxy";
    };

    systemd.services."fcitx5-lotus-server" = {
      enable = true;
      description = "Fcitx5 Lotus Server";
      documentation = ["https://github.com/LotusInputMethod/fcitx5-lotus"];
      after = ["multi-user.target" "udev.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        User = "uinput_proxy";
        Group = "input";
        Type = "simple";
        ExecStartPre = "${pkgs.acl}/bin/setfacl -m u:uinput_proxy:rw /dev/uinput";
        ExecStart = "${fcitx5-lotus-pkg}/bin/fcitx5-lotus-server -u ${username}";
        Restart = "on-failure";
        RestartSec = "0";
      };
    };
  };
}
