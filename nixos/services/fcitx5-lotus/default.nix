{
  config,
  pkgs,
  username,
  mkModule,
  ...
}:
# Tang HE THONG cua fcitx5-lotus. Addon fcitx5 thi da co san o
# home-manager/environments/i18n (`i18n.inputMethod.fcitx5.addons`); module nay
# CHI them ba thu ma home-manager khong voi toi duoc, va thieu ca ba thi bon che
# do Uinput cua lotus chet lang le.
#
# Vi sao can: lotus co 6 che do go (bam `` ` `` de mo menu). Bon che do dau —
# Uinput (Muot/Cham/Sieu muot) va Minecraft — KHONG dung preedit va KHONG dung
# surrounding text; chung nho mot daemon dac quyen `fcitx5-lotus-server` phat
# BackSpace that qua /dev/uinput, dung co che cua Go Nhanh tren macOS va VKey
# tren Windows. Hai che do con lai (`Van ban xung quanh`, `Gach chan`) thi dung
# duong fcitx5 thong thuong, va trong kitty ca hai deu ra gach chan: kitty la
# luong byte nen khong cap surrounding text, IME buoc phai quay ve preedit.
#
# nixpkgs dong goi day du binary + unit + udev rule (da va duong dan sang store)
# nhung KHONG kem module NixOS, nen mac dinh khong ai nap unit lan rule. Khong
# co server ⇒ bon che do Uinput im lang khong chay ⇒ chi con duong preedit.
# Day chinh la trang thai rog truoc 16/08/2026.
mkModule config ./. {
  # `uinput_proxy` la user ma unit thuong nguon chay duoi, khong phai user cua
  # phien. Nhom `input` co san tren NixOS.
  users.users.uinput_proxy = {
    isSystemUser = true;
    group = "input";
  };

  # 99-lotus.rules: dat /dev/uinput ve 0660 root:input roi setfacl them quyen
  # rw cho uinput_proxy. Khong co rule nay thi server mo /dev/uinput that bai
  # va thoat, systemd restart vong tron — trieu chung o phia nguoi dung chi la
  # "chon che do Uinput nhung van gach chan".
  services.udev.packages = [pkgs.fcitx5-lotus];

  # Nap unit template fcitx5-lotus-server@.service tu goi. `systemd.packages`
  # CHI nap chu KHONG bat: NixOS bo qua `[Install] WantedBy=` cua unit den tu
  # goi, nen phai noi day tay o duoi.
  systemd.packages = [pkgs.fcitx5-lotus];

  # Mot instance cho moi nguoi dung. Server can biet user nao de doi chieu voi
  # tien trinh fcitx5 dang chay (`-u %i`). `username` doc $USER LUC EVAL, nen
  # kiem tu may khac se thay ten cua may do — tren rog no ra `kln`.
  systemd.targets.multi-user.wants = ["fcitx5-lotus-server@${username}.service"];
}
