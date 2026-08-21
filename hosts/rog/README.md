# rog — ASUS ROG Strix G531GT (NixOS · GNOME + sway + hyprland + niri)

i5-9300H · 8 GB RAM · NVMe 476,9 GiB · UHD 630 + GTX 1650 Mobile (Optimus, PRIME offload).

GPU rời không tự chạy — gọi từng app một:

```sh
nvidia-offload <lệnh>
```

Rebuild (shell alias: `update`):

```sh
sudo nixos-rebuild switch --impure --flake ~/.nix#rog
```

## Bốn session, chọn ở GDM

Máy này cài **bốn** môi trường; chọn bằng nút bánh răng ở màn đăng nhập GDM.
Không có phiên X11 nào — `share/xsessions` rỗng.

| Session | Config | Áp dụng thay đổi phím |
|---|---|---|
| GNOME | dconf, sinh lúc eval | `nixos-rebuild switch` |
| sway | `home-manager/environments/sway/sway.d` | switch, rồi `Tab+r` |
| hyprland | `home-manager/environments/hyprland/hypr.d` | switch, rồi `Tab+r` |
| niri | `home-manager/environments/niri/niri.d` | — chưa nối phím launcher (cố ý) |

GNOME cố ý ở lại làm lưới an toàn: cấu hình sway/hyprland/niri hỏng cũng không
khoá được người dùng khỏi máy. Phím tắt launcher của GNOME/sway/hyprland đến từ
**một** file `configs/shortcuts/launch-app.toml`; niri chưa được nối vào.

Sau khi `switch`, chỉ cần **đăng xuất** để đổi session — không phải reboot.

## hyprland: config là Lua, không còn hyprlang

`hypr.d/` chỉ còn `.lua`; cây `.conf` đã xoá 20/08/2026 sau khi một phiên đăng
nhập thật xanh hết checklist dưới đây. Bối cảnh và ba cái bẫy của API mới nằm ở
`CLAUDE.md`, mục "Hyprland trên rog".

**Sàn beckon là 0.9.21.** Bản cũ hơn lái compositor bằng `dispatch exec …` —
phương ngữ hyprlang — nên trên config Lua **mọi phím tắt launcher chết**, và
dấu hiệu duy nhất là một dòng stderr mỗi lần bấm. Đây là lỗi của công cụ, đã
sửa ở thượng nguồn (`xom11/beckon` v0.9.21) rồi bump `flake.lock`.

Đo 20/08/2026 trên một phiên đăng nhập thật:

| Kiểm | Kết quả |
|---|---|
| `grep '\[cfg\]' <log>` | `Using lua config found at ~/.config/hypr/hyprland.lua` |
| `Hyprland --verify-config` | `config ok`, thoát 0 — và **đỏ thật** khi cố ý làm hỏng (thoát 1, kèm `file:dòng`, kể cả trong file được `require`) |
| `hyprctl binds -j \| grep -c modmask` | 80 (đúng bằng bản `.conf`) |
| `hyprctl binds -j` → `handler` | `__lua` ở cả 80 |
| binding theo submap | 69 gốc + 11 `resize` |
| `hyprctl configerrors` | rỗng |
| `hyprctl monitors all` | HDMI-A-1 bật, eDP-1 `disabled: true` |
| `/sys/class/drm/card1-eDP-1/enabled` | `disabled` |
| `Explicit device list` trong log | `/dev/dri/nvidia-card:/dev/dri/intel-card`, `card0 becomes primary` — tức `hl.env` kịp trước backend DRM |
| `grep -c 'cursor blit failed'` | 0 |
| exec-once (mako, swaybg, swayidle, kanshi, fcitx5) | cả 5 đang chạy |
| `beckon check apps.shared.toml` | `ok: 20 shortcuts`; focus/launch/chuỗi `\|\|` đều chạy |

**`grep -c 'forcing linear'` là 3, không phải 0** — cả 3 nằm ở dòng 296–304 của
686, tức lúc modeset HDMI-A-1 khi khởi động, và con số này giống hệt phiên
trước khi chuyển sang Lua. Triệu chứng thật của lỗi GPU cũ là `cursor blit
failed` (85.848 lần), và nó bằng 0.

**Đếm tiến trình phải dùng `ps -eo args`**, không phải `pgrep -x`: nixpkgs bọc
binary thành `.NAME-wrapped`, nên `pgrep -x mako` trả 0 trong khi mako đang
chạy — đã dính đúng bẫy này khi chạy checklist trên.

## Bố cục ổ

| # | Phân vùng | Kích thước | Dùng cho |
|---|---|---|---|
| p1 | `disk-main-ESP` | 1G | `/boot` |
| p2 | `disk-main-root` | 459,9G | `/` (ext4) |
| p3 | `disk-main-swap` | 16G | swap + hibernate (`resumeDevice`) |

Toàn bộ ổ. ESP 1G thay vì 512M như thường lệ — di sản từ thời chia đôi ổ với
Windows, không đáng thu hẹp lại.

## Windows đã bỏ hẳn (14/08/2026)

Máy này từng dual-boot Windows 11 trong đúng một ngày. Bỏ sau hai lần thất bại:

1. **Lần một** — cài được, chạy được, rồi Windows Update (feature update, `pending.xml`
   98,5 MB) làm máy không boot nổi. Bản thân update áp **thành công** (`poqexec`
   trả `S_OK`); máy chết sau đó và rơi vào vòng lặp Automatic Repair không thoát ra được.
2. **Lần hai** — cài lại bằng ISO 25H2 chính chủ; trình cài boot từ USB lại
   không nhìn thấy ổ nào.

Chủ máy quyết định dừng. Ổ đã nới hết cho NixOS, `EFI/Microsoft` và mục boot
`Windows Boot Manager` đã xoá.

Bài học còn giá trị nếu ngày nào đó làm lại: đừng cài từ ISO cũ. Bản dùng lần một
là 24H2 RTM (tháng 4/2024), nên ngay sau khi cài Windows phải nhảy một bước
nâng cấp build khổng lồ — và đó chính là bước đã gãy.

## Cài lại từ đầu

`disko.sh` **xoá sạch ổ**. Chạy từ NixOS live USB, không chạy trên hệ đang sống:

```sh
./hosts/rog/disko.sh
```
