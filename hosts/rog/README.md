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

## Bố cục ổ — thực tế sau khi cài Windows (14/08/2026)

| # | Phân vùng | Kích thước | Ai quản |
|---|---|---|---|
| p1 | `disk-main-ESP` | 1G | disko — `/boot`, **dùng chung** systemd-boot + Windows Boot Manager |
| p2 | `disk-main-root` | 222G | disko — `/` (ext4) |
| p3 | `disk-main-swap` | 16G | disko — swap + hibernate (`resumeDevice`) |
| — | *(trống)* | 6G | chỗ phân vùng dựng bộ cài Windows, đã xoá |
| p5 | Microsoft reserved | 16M | **Windows** |
| p6 | Basic data (NTFS) | 231,3G | **Windows** |
| p7 | *(recovery, NTFS)* | 598M | **Windows** |

`disko.nix` chỉ khai báo p1–p3 rồi để trống phần còn lại. Ba phân vùng Windows
nằm ngoài tầm Nix — `nixos-rebuild` không bao giờ đụng tới chúng.

## ⚠️ `disko.sh` giờ xoá cả Windows

Lúc viết, `disko.sh` chỉ xoá một cái NixOS trống. **Bây giờ nó xoá sạch cả bản
Windows ở p5–p7**, vì `--mode disko` huỷ toàn bộ `/dev/nvme0n1` chứ không chỉ
các phân vùng nó khai báo. Chỉ chạy khi thực sự muốn dựng lại từ số không.

## Chọn hệ điều hành lúc khởi động

Không cần khai báo gì: systemd-boot quét ESP, thấy
`EFI/Microsoft/Boot/bootmgfw.efi` và tự thêm mục `Windows Boot Manager`
(`bootctl list` → `id: auto-windows`). Menu chờ 5 giây.

Trình cài Windows **luôn tự đẩy mình lên đầu `BootOrder` của UEFI**. Sau mỗi lần
cài lại Windows phải trả về:

```sh
sudo efibootmgr                  # tìm số của Linux Boot Manager
sudo efibootmgr -o 0001,...      # đặt nó lên trước
```

## Cài lại từ đầu

```sh
./hosts/rog/disko.sh
```

Chạy từ NixOS live USB, không chạy trên hệ đang sống. Đọc cảnh báo ở trên trước.
