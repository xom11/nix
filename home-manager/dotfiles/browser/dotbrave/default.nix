# Brave nhu mot dotfile. Chia doi theo quyen han:
#   [shortcuts] + [settings] -- CLI dotbrave chay o day, quyen user.
#   [pwa]                    -- services.dotbrave o tang he thong ghi,
#                               noi rebuild von da chay bang root.
# Nen activation nay khong bao gio hoi sudo. `--unattended` con bao dam no
# khong dong Brave dang chay va khong lam hong rebuild.
#
# brave.toml tro bang CHUOI qua getPath, khong phai path literal: sua toml
# la an ngay o lan activation sau, khong can rebuild. Nhung [pwa] thi Nix
# doc luc EVAL, nen sua danh sach PWA VAN phai rebuild.
#
# Hai diem khac voi ban nhap ban dau, ca hai da kiem chung bang eval that:
#   - Flake input den thang bang TEN RIENG (o day la `dotbrave`), khong qua
#     mot bien `inputs` gop chung -- repo nay khong truyen `inputs` lam
#     specialArg (xem lib/mkConfigs.nix: `args = inputs // {...}`, spread
#     tung input ra ngoai). Dung `inputs,` lam tham so van eval "duoc" luc
#     goi ham, Nix chi bao loi luc THUC SU dung no -- va no bao "attribute
#     inputs missing", khong phai loi option "does not exist" nhu tuong.
#   - `imports` phai nam o dinh module, KHONG duoc long trong noi dung dua
#     vao `mkModule` (noi dung do roi vao `config`, bi `lib.mkIf cfg.enable`
#     boc lai). NixOS/home-manager chi doc khoa `imports` o cap module thô,
#     con `imports` nam trong `config` chi la du lieu binh thuong -- ket qua
#     la loi "home-manager.users.<user>.imports, which is an option that
#     does not exist". Import module ngoai phai vo dieu kien (chinh vi vay
#     NixOS khong cho import co dieu kien), roi hop voi phan options/config
#     ma `mkModule` tra ve bang `//`. Cach nay dung dung nguyen tac da co
#     trong repo: autoImport da nap moi default.nix vao MOI host bat ke co
#     bat enable hay khong (mot module khong ai bat van khai bao options
#     tren moi rebuild), nen import vo dieu kien o day khong mo rong pham
#     vi gi so voi hmModules trong lib/mkConfigs.nix -- chi la lam cung
#     viec do o cap module thay vi cap builder.
{
  config,
  dotbrave,
  getPath,
  mkModule,
  ...
}:
{
  imports = [dotbrave.homeManagerModules.default];
}
// mkModule config ./. {
  programs.dotbrave = {
    enable = true;
    config = "${getPath ./.}/brave.toml";
    skip = ["pwa"];
  };
}
