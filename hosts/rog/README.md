# rog — ASUS ROG Strix G531GT (NixOS · GNOME + sway + hyprland)

i5-9300H · 8 GB RAM · NVMe 476,9 GiB · UHD 630 + GTX 1650 Mobile (Optimus, PRIME offload).

GPU rời không tự chạy — gọi từng app một:

```sh
nvidia-offload <lệnh>
```

Rebuild (shell alias: `update`):

```sh
sudo nixos-rebuild switch --impure --flake ~/.nix#rog
```

## Ba session, chọn ở GDM

Máy này cài **ba** môi trường; chọn bằng nút bánh răng ở màn đăng nhập GDM.

| Session | Config | Áp dụng thay đổi phím |
|---|---|---|
| GNOME | dconf, sinh lúc eval | `nixos-rebuild switch` |
| sway | `home-manager/environments/sway/sway.d` | switch, rồi `Tab+r` |
| hyprland | `home-manager/environments/hyprland/hypr.d` | switch, rồi `Tab+r` |

GNOME cố ý ở lại làm lưới an toàn: cấu hình sway/hyprland hỏng cũng không khoá
được người dùng khỏi máy. Phím tắt launcher của cả ba đến từ **một** file
`configs/shortcuts/apps.linux.toml`.

Sau khi `switch`, chỉ cần **đăng xuất** để đổi session — không phải reboot.

## Bố cục ổ

| # | Phân vùng | Kích thước | Dùng cho |
|---|---|---|---|
| p1 | `disk-main-ESP` | 1G | `/boot` |
| p2 | `disk-main-root` | 459,9G | `/` (ext4) |
| p3 | `disk-main-swap` | 16G | swap + hibernate (`resumeDevice`) |

Toàn bộ ổ. Giống `hosts/x1g6/disko.nix`, chỉ khác ESP 1G thay vì 512M — di sản
từ thời chia đôi ổ với Windows, không đáng thu hẹp lại.

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
