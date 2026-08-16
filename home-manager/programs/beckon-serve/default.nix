{
  config,
  pkgs,
  repoPath,
  mkModule,
  ...
}: let
  # Chuoi tro thang working tree (triet ly mkOutOfStoreSymlink): sua file la
  # watcher cua serve tu ap dung, khong can switch.
  configFile = "${repoPath}/configs/shortcuts/apps.shared.toml";
  label = "com.xom11.beckon-serve";
  logDir = "${config.home.homeDirectory}/Library/Logs/beckon";
in
  mkModule config ./. {
    # launchd KHONG tu tao thu muc cha cho StandardOutPath — agent se khong
    # start noi tren may sach. .keep la cach khai bao thuan HM, thay cho mot
    # activation script chi de mkdir.
    home.file."Library/Logs/beckon/.keep".text = "";

    launchd.agents.beckon-serve = {
      enable = true;
      config = {
        Label = label;
        # Tro THANG vao store, khong qua path on dinh nao. Bo cai do 10/08/2026
        # cung luc bo tinh nang cycle cua so — xem README cung thu muc.
        # Tom tat: beckon chi can Accessibility cho 2 viec (xoay cua so trong
        # cung mot app, va dem cua so de dung day app da minimize het). Bat
        # phim tat, mo app, focus app, nhay ve app truoc, an app: KHONG can
        # quyen gi. Khong grant thi khong can path co dinh de treo grant vao.
        #
        # Va vi store path nam trong plist, moi lan bump beckon la plist doi;
        # HM so plist bang `cmp -s` roi bootout + bootstrap lai (xem
        # setupLaunchAgents/processAgent trong activate script), nen agent tu
        # chay binary moi. Do la ly do khong con `launchctl kickstart -k`.
        ProgramArguments = ["${pkgs.beckon}/bin/beckon" "serve" configFile];
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
