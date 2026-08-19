{
  config,
  lib,
  getRelPath,
  ...
}: let
  relPath = getRelPath ./.;
  pathList = ["modules"] ++ (lib.splitString "/" relPath);
  cfg = lib.getAttrFromPath pathList config;
in {
  # greetd + ReGreet. HAI THU, khong phai mot -- va day la diem de hieu nham
  # nhat cua ca cum nay:
  #
  #   greetd   daemon. Xac thuc PAM, khoi dong session. KHONG VE GI CA.
  #   ReGreet  greeter. Ve giao dien GTK4, chay ben trong `cage` (mot
  #            compositor kiosk mot-cua-so).
  #
  # greetd mot minh khong dung duoc: no bat buoc phai co mot greeter. Do la
  # chu dich cua no -- tach "xac thuc + chay phien" khoi "ve man hinh", nguoc
  # han GDM/SDDM von gop ca hai vao mot khoi khong thay duoc.
  #
  # `services.displayManager.regreet` cua nixpkgs lo het phan noi day: no tu
  # bat `services.greetd`, tu dung `default_session.command` chay ReGreet
  # trong cage, va sinh /etc/greetd/regreet.{toml,css}. Nen o day chi can mot
  # dong `enable`.
  config = lib.mkIf (cfg.enable && cfg.displayManager == "regreet") {
    services.displayManager.regreet.enable = true;

    # Dark mode. `application_prefer_dark_theme` la khoa CHINH THUC cua ReGreet
    # cho viec nay (regreet.sample.toml cua upstream), va no di CUNG
    # `theme_name = "Adwaita"` chu khong thay bang "Adwaita-dark": GTK4 tu chon
    # bien the toi cua theme khi co co nay. Module NixOS da dat san theme_name
    # tu `regreet.theme.name`, o day chi ghep them mot khoa nen hai ben merge
    # binh thuong.
    #
    # Neu sau nay muon them anh nen thi ReGreet co `[background] path` + `fit`,
    # va mot dong chao o `[appearance] greeting_msg`.
    services.displayManager.regreet.settings.GTK.application_prefer_dark_theme = true;

    # BAT BUOC, va la thu se noi doi neu quen.
    #
    # `nixos/base` bat `services.displayManager.autoLogin` cho MOI host NixOS.
    # Nhung option do duoc cac module GDM/SDDM/LightDM tieu thu -- greetd
    # KHONG doc no. De nguyen `true` thi eval van xanh, rebuild van xanh, va
    # khong co canh bao nao; chi la khi bat may len thi no khong tu dang nhap,
    # con `nix eval` van bao autoLogin = true. Mot cau hinh noi doi.
    #
    # Muon tu dang nhap voi greetd thi phai khai `initial_session` cua chinh
    # no (`services.greetd.settings.initial_session`), la mot co che khac han.
    # CO Y khong lam o day: mot phien duoc ghim cung ma hong thi may vao thang
    # cho hong, khong kip chon phien khac -- dung the bi da gap tren rog.
    services.displayManager.autoLogin.enable = lib.mkForce false;
  };
}
