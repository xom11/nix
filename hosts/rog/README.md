# rog — ASUS ROG Strix G531GT (NixOS · GNOME · dual-boot Windows)

i5-9300H · 8 GB RAM · NVMe 476,9 GiB · UHD 630 + GTX 1650 Mobile (Optimus, PRIME offload).

GPU rời không tự chạy — gọi từng app một:

```sh
nvidia-offload <lệnh>
```

Rebuild (shell alias: `update`):

```sh
sudo nixos-rebuild switch --impure --flake ~/.nix#rog
```

## Bố cục ổ

| Phân vùng | Kích thước | Dùng cho |
|---|---|---|
| `ESP` | 1G | `/boot` — **dùng chung** systemd-boot + Windows Boot Manager |
| `root` | 222G | `/` (ext4) |
| `swap` | 16G | swap + hibernate (`resumeDevice`) |
| *(trống)* | ~238G | Windows tự tạo MSR + NTFS + recovery ở đây |

## Cài lại từ đầu

`disko.sh` **xoá sạch ổ**. Chạy từ NixOS live USB, không chạy trên hệ đang sống:

```sh
./hosts/rog/disko.sh
```

Rồi cài Windows vào vùng trống — trình cài Windows tự thấy ~238G chưa phân vùng.
Cài xong Windows sẽ tự đặt mình lên đầu thứ tự boot của UEFI; trả lại bằng cách
chọn `Linux Boot Manager` trong BIOS, hoặc từ NixOS:

```sh
sudo efibootmgr          # xem thứ tự hiện tại
sudo efibootmgr -o XXXX,YYYY   # đặt Linux Boot Manager lên trước
```
