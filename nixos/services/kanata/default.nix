{
  config,
  lib,
  pkgs,
  mkModule,
  ...
}: let
  # CA THU MUC configs/kanata vao store, khong phai rieng mot file: kanata giai
  # nghia `include` tuong doi voi thu muc cua file cfg, nen defcfg.kbd/main.kbd
  # phai nam canh kanata_linux.kbd thi moi phan giai duoc.
  #
  # Nho vay NixOS va Ubuntu (system-manager) doc CHUNG mot kanata_linux.kbd.
  # Truoc day phai co kanata_nixos.kbd rieng chi vi hai dong `include`: module
  # nixpkgs nhan `config` la CHUOI, ma chuoi do duoc ghi ra mot file store don
  # doc — khong co file anh em ben canh nen include chet.
  #
  # `configFile` ghi de moi option khac cua module (extraDefCfg, devices...),
  # ke ca dong `linux-continue-if-no-devs-found yes` ma module von tu chen. Da
  # bu lai bang cach dua dong do vao defcfg.kbd dung chung — kanata 1.12 chap
  # nhan key `linux-*` tren macOS (da chay `--check` de xac nhan), nen no khong
  # lam hong hai nen tang kia.
  #
  # Module chi chay `--check` luc build cho file NO TU SINH, khong kiem file
  # nguoi dung dua vao. Nen tu dung lai buoc do o day, keo mat hang rao.
  configDir = pkgs.runCommand "kanata-config" {} ''
    cp -r ${../../../configs/kanata} $out
    chmod -R u+w $out
    ${lib.getExe pkgs.kanata} --cfg $out/kanata_linux.kbd --check --debug
  '';
in
  mkModule config ./. {
    services.kanata = {
      enable = true;
      package = pkgs.kanata;
      keyboards = {
        default = {
          configFile = "${configDir}/kanata_linux.kbd";
        };
      };
    };
  }
