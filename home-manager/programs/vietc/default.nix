# Viet+ (vietc) — bo go tieng Viet direct-input, chay thay cho fcitx5.
#
# CHUA BAT O HOST NAO, va do la co y. Doc muc "Ba duong" ben duoi truoc khi bat:
# tren GNOME module nay gan nhu chac chan KHONG giai quyet duoc gach chan trong
# kitty, con tren sway/hyprland thi co.
#
# ## Ba duong, vietc tu chon MOT lan luc khoi dong (daemon/src/main.rs)
#
# 1. zwp_input_method_v2 — rootless, phu ca app Wayland native ke ca kitty.
#    sway va Hyprland co protocol nay. Day la duong DUY NHAT ta muon dung.
# 2. evdev grab + uinput — phu moi thu nhung phai o group `input` va EVIOCGRAB
#    ban phim that. rog dang chay kanata, ma kanata grab ban phim roi; hai thu
#    cung grab la tranh nhau. Vi vay `grab = false` trong config.toml.
# 3. X11 XTEST — chi can DISPLAY, nhung CHI phu cua so X11/XWayland. kitty chay
#    Wayland native nen KHONG duoc phu. Day la duong vietc roi vao tren GNOME,
#    va la ly do bat module nay tren GNOME la vo ich.
#
# Mutter KHONG co zwp_input_method_v2 (do duoc tren rog: log fcitx5 in
# "Using Wayland native input method protocol: 0"), nen duong 1 chi mo ra sau
# khi rog vao session sway/hyprland.
#
# ## Bat the nao
#
# Trong hosts/<device>/home.nix:
#   modules.home-manager.programs.vietc.enable = true;
#
# Va phai TAT fcitx5 cung luc, neu khong hai bo go cung an phim:
#   - bo `environments.i18n.enable`
#   - sway.d/conf.d/system.conf: bo dong `exec_always fcitx5 -rd`
#   - sway.d/conf.d/tab.conf: $tab+w / $tab+e dang goi `fcitx5-remote -s ...`,
#     doi sang `vietcctl` (hoac bo han vi vietc tu co toggle_key).
# Khong co assertion nao bat loi nay — hai bo go cung chay thi trieu chung la
# chu nhay hoac an phim, khong phai loi.
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
    home.packages = [pkgs.vietc];

    # Daemon doc ~/.config/vietc/config.toml. Symlink out-of-store an toan o day
    # vi daemon chi DOC file nay — thu no ghi la overrides.toml ben canh, va file
    # do co y de nguyen cho daemon so huu (bai hoc fcitx5: profile symlink vao
    # repo bi chinh fcitx5 ghi de xuyen symlink).
    home.file."${config.xdg.configHome}/vietc/config.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${pwd}/vietc.d/config.toml";
    };

    systemd.user.services.vietc = {
      Unit = {
        Description = "Viet+ Vietnamese IME daemon";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.vietc}/bin/vietc";
        Restart = "on-failure";
        RestartSec = 3;
        # Upstream giai thich: IbusRestartGuard sinh ibus-daemon trong cgroup cua
        # service, kill mode `control-group` mac dinh se giet luon IBus khi dung
        # vietc — va the la khong con bo go nao.
        KillMode = "process";
      };

      # Unit upstream con co ConditionEnvironment=DISPLAY. CO Y KHONG chep sang:
      # dieu kien do sinh ra de ep vietc xuong duong X11 (3) cho chac, nhung o
      # day ta muon dung duong v2 (1) tren sway — noi DISPLAY co the khong ton
      # tai neu khong chay XWayland. Giu lai la service im lang khong bao gio
      # khoi dong.
      Install.WantedBy = ["graphical-session.target"];
    };
  }
