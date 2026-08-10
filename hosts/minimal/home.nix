{ pkgs, lib, username, ... }:
let
  # Host nay ton tai de tra loi mot cau: tren may la nay, nix va script cai dat
  # co chay khong? Nen no phai bam theo $HOME THAT cua may dang chay, chu khong
  # doan theo quy uoc he dieu hanh — may co the la Termux
  # (/data/data/com.termux/files/home), container, hay mot may cong ty dat home
  # o cho khac.
  envHome = builtins.getEnv "HOME";
in
{
  imports = [
    ../../home-manager
  ];

  # mkForce la BAT BUOC, khong phai cho dep: home-manager/base dat
  # home.homeDirectory theo he DICH (isDarwin ? /Users/... : /home/...). Hai gia
  # tri chi trung nhau khi $HOME cua may dang eval khop quy uoc cua he dich, nen
  # neu khong force thi eval cheo he se chet vi "conflicting definition values".
  #
  # Cu the: CI chay runner Linux ($HOME=/home/runner, $USER=runner) nen hai ben
  # trung nhau va LUON xanh — tuc CI ve mat cau truc KHONG BAO GIO bat duoc loi
  # nay. No chi lo ra khi eval `minimal` cho x86_64-linux tu mot may Mac, dung
  # cach `.github/workflows/eval.yml` khong lam. Do ngay 10/08/2026.
  #
  # Du phong khi $HOME rong (eval trong moi truong khong co bien do): roi ve
  # dung cong thuc cua base, thay vi de home-manager nhan mot duong dan rong.
  home.homeDirectory = lib.mkForce (
    if envHome != ""
    then envHome
    else if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}"
  );
  home.sessionVariables = {
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
  };
  modules.home-manager = {
    programs = {
      zsh.enable = true;
      ssh.enable = true;
    };
  };
}
