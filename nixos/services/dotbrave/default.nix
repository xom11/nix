# Toan bo dotbrave cho mot host NixOS, bat bang MOT dong.
#
# dotbrave chia doi theo QUYEN HAN: `[pwa]` ghi vao /etc/brave/policies/managed/
# nen can root, con `[shortcuts]` + `[settings]` ghi vao profile Brave cua user
# nen phai chay bang user. Do la chi tiet cai dat cua dotbrave -- khong co ly do
# gi bat host phai khai hai lan. Nen module nay so huu ca hai nua: no dat
# `services.dotbrave` o tang he thong VA bat module home-manager anh em cho
# `username`.
#
# Lam duoc la nho lib/mkConfigs.nix noi home-manager vao NHU MOT MODULE NixOS
# (`home-manager.users.<name>`), chu khong phai builder rieng. He qua phai nho:
# cach nay CHI dung cho host NixOS/darwin. Host home-manager standalone
# (`server`, `desktop`, `minimal`) khong co tang root nao, muon dung dotbrave
# thi bat thang `modules.home-manager.dotfiles.browser.dotbrave` -- va o do chi
# co duoc hai bang kia, `[pwa]` nam ngoai tam voi.
#
# Danh doi da can: bat mot module lai ngam bat mot module khac, hoi nguoc voi
# chu truong "moi host doc nhu mot ban kiem ke day du" trong CLAUDE.md. Chap
# nhan vi cai thay the con te hon -- hai dong o hai file, ma quen mot dong thi
# KHONG co loi nao no ra, chi la mot nua brave.toml im lang khong duoc ap.
#
# Duong /etc/brave/policies/managed/ la duong DA DO tren rog chu khong suy tu
# ban .deb cua Brave: `grep -a` chinh ELF cua pkgs.brave 1.93.129 tra ve
# "/etc/brave/policies" (canh "/etc/chromium/policies"). Neu mai nixpkgs doi
# cach dong goi Brave thi phai do lai -- module upstream ghi mot duong CO DINH,
# no khong hoi trinh duyet xem doc o dau.
#
# `config` la CHUOI tuyet doi qua repoPath, khong phai path literal: path
# literal se chep brave.toml vao store va dong bang no o do. Nhung khac
# [shortcuts]/[settings], sua [pwa] VAN phai rebuild -- Nix doc no bang
# builtins.readFile luc EVAL, nen no la dau vao cua eval chu khong phai mot
# dotfile duoc doc luc chay. readFile lam eval IMPURE; rieng repo nay khong ton
# them gi vi lib/mkConfigs.nix von da doc $USER va builtins.currentSystem.
#
# `imports` phai nam o DINH module, ngoai `mkModule`. Long vao trong thi noi
# dung do roi vao `config` va bi lib.mkIf boc lai; NixOS chi doc khoa `imports`
# o cap module thô nen loi bao ra la "imports, which is an option that does not
# exist" -- khong he goi y nguyen nhan that.
{
  config,
  dotbrave,
  mkModule,
  repoPath,
  username,
  ...
}:
{
  imports = [dotbrave.nixosModules.default];
}
// mkModule config ./. {
  services.dotbrave = {
    enable = true;
    config = "${repoPath}/home-manager/dotfiles/browser/dotbrave/brave.toml";
  };

  home-manager.users.${username}.modules.home-manager.dotfiles.browser.dotbrave.enable = true;
}
