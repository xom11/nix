{
  config,
  pkgs,
  mkModule,
  getPath,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # Module nay mang luon CHUONG TRINH, khong chi config. Truoc day binary
    # `rofi` chi den tu environments/{i3wm,sway}, nen host nao bat
    # dotfiles.rofi ma khong dung i3/sway (vi du GNOME) se co config.rasi +
    # theme.rasi duoc trien khai cho mot chuong trinh KHONG TON TAI -- do
    # tren VM GNOME 09/08/2026. Cung lop loi voi `kitty`: config o mot module,
    # goi o mot module khac, va khong gi bao khi chi bat mot nua.
    # i3wm/sway van liet ke rofi trong home.packages cua chung; trung nhau vo
    # hai vi home.packages la hop tap.
    home.packages = [pkgs.rofi];

    home.file = {
      ".config/rofi/config.rasi" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config.rasi";
      };
      ".config/rofi/theme.rasi" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/theme.rasi";
      };
    };
  }
