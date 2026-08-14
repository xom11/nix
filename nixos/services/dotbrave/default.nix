# [pwa] o tang he thong. Doi ung tren NixOS cua khoi `services.dotbrave` ma
# hosts/macmini/configuration.nix khai qua `dotbrave.darwinModules.default`:
# nixos-rebuild von chay bang root nen ghi duoc /etc/brave/policies/managed/
# ma khong hoi sudo giua activation.
#
# Cap voi `home-manager/dotfiles/browser/dotbrave` chu khong thay the no. Ben
# do chay CLI o quyen user cho [shortcuts] + [settings] va CO Y `skip = ["pwa"]`,
# nhuong ca namespace pwa cho file nay. Bat mot ben ma quen ben kia thi khong
# co loi nao no ra -- chi la mot nua brave.toml im lang khong duoc ap.
#
# Duong /etc/brave/policies/managed/ la duong DA DO tren rog, khong phai suy tu
# ban .deb cua Brave: `grep -a` chinh ELF cua pkgs.brave 1.93.129 tra ve
# "/etc/brave/policies" (canh "/etc/chromium/policies"). Neu mai nixpkgs doi
# cach dong goi Brave thi phai do lai -- module nay ghi mot duong CO DINH do
# upstream dotbrave chon, no khong hoi trinh duyet xem doc o dau.
#
# `config` la CHUOI tuyet doi qua repoPath, khong phai path literal: path
# literal se chep brave.toml vao store va dong bang no o do. Nhung khac
# [shortcuts]/[settings], sua [pwa] VAN phai rebuild -- Nix doc no bang
# builtins.readFile luc EVAL, nen no la dau vao cua eval chu khong phai mot
# dotfile duoc doc luc chay.
#
# Doc file bang readFile lam eval IMPURE. Rieng repo nay khong ton them gi:
# lib/mkConfigs.nix da doc $USER va builtins.currentSystem nen moi lenh rebuild
# o day von da phai co --impure.
#
# `imports` phai nam o DINH module, ngoai `mkModule`. Long vao trong thi noi
# dung do roi vao `config` va bi lib.mkIf boc lai; NixOS chi doc khoa `imports`
# o cap module thô nen loi bao ra la "imports, which is an option that does not
# exist" -- khong he goi y nguyen nhan that. Cung cach ma module home-manager
# anh em dang lam.
{
  config,
  dotbrave,
  mkModule,
  repoPath,
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
}
