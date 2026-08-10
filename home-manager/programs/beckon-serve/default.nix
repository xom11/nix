{
  config,
  lib,
  pkgs,
  repoPath,
  mkModule,
  ...
}: let
  # TCC: beckon dung AX API (cycle cua so). Lam launchd agent thi beckon TU
  # chiu TCC — ma path trong store doi moi rebuild, grant chet theo. Copy ra
  # path on dinh NGOAI store (tien le kanata-Homebrew). ~/.local/libexec chu
  # KHONG phai ~/.local/bin: dir do dung truoc nix trong PATH va se shadow
  # CLI `beckon` cua home.packages (vet xe ~/.local/bin/herdr).
  binDir = "${config.home.homeDirectory}/.local/libexec";
  bin = "${binDir}/beckon";
  # Chuoi tro thang working tree (triet ly mkOutOfStoreSymlink): sua file la
  # watcher cua serve tu ap dung, khong can switch.
  configFile = "${repoPath}/configs/shortcuts/apps.macos.toml";
  label = "com.xom11.beckon-serve";
  logDir = "${config.home.homeDirectory}/Library/Logs/beckon";
in
  mkModule config ./. {
    home.activation.beckonServeBinary = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # PATH cua activation chi co store paths: coreutils dung ten tran duoc,
      # launchctl PHAI la /bin/launchctl tuyet doi. $DRY_RUN_CMD theo house
      # style (xem home-manager/base/default.nix).
      mkdir -p ${lib.escapeShellArg binDir} ${lib.escapeShellArg logDir}
      beckonNew="$(sha256sum ${pkgs.beckon}/bin/beckon | cut -d' ' -f1)"
      beckonOld=""
      [ -f ${lib.escapeShellArg bin} ] \
        && beckonOld="$(sha256sum ${lib.escapeShellArg bin} | cut -d' ' -f1)"
      if [ "$beckonNew" != "$beckonOld" ]; then
        $DRY_RUN_CMD install -m 755 ${pkgs.beckon}/bin/beckon ${lib.escapeShellArg bin}
        # Restart agent de no chay binary moi. Lan dau (agent chua load) lenh
        # nay truot — RunAtLoad cua lan load ngay sau activation lo — nen || true.
        $DRY_RUN_CMD /bin/launchctl kickstart -k "gui/$(id -u)/${label}" || true
      fi
    '';

    launchd.agents.beckon-serve = {
      enable = true;
      config = {
        Label = label;
        ProgramArguments = [bin "serve" configFile];
        RunAtLoad = true;
        # Serve khong bao gio thoat "thanh cong" — chet la relaunch. Throttle
        # 60s theo bai agenix: khong crash-loop 10s khi binary/config hong.
        KeepAlive = {SuccessfulExit = false;};
        ThrottleInterval = 60;
        # Hotkey chi song trong phien GUI. Day cung la thu chan cai bay
        # "khoi dong tu SSH khong nhan event": launchd luon dat agent vao
        # dung phien Aqua.
        LimitLoadToSessionType = "Aqua";
        StandardOutPath = "${logDir}/serve.log";
        StandardErrorPath = "${logDir}/serve.log";
      };
    };
  }
