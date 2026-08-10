# ATTIC — code đã gỡ khỏi cây

Xoá **không** làm mất code: repo này public và history vĩnh viễn, nên commit ngay
trước mỗi lần gỡ vẫn là tổ tiên của `main` và không bao giờ bị GC. Thứ dễ mất là
*khả năng tìm* — bảng này và các tag `attic/*` giữ đúng cái đó.

Liệt kê nhanh mọi thứ từng bị gỡ:

```sh
git tag -l 'attic/*'
```

## Đã gỡ

| Thứ | Đường dẫn cũ | Gỡ ngày | Tag | Vì sao |
|---|---|---|---|---|
| karabiner (dotfiles) | `home-manager/dotfiles/macos/karabiner` | 2026-08-10 | `attic/karabiner-2026-08-10` | Thay bằng kanata. **Cask `karabiner-elements` và launchd daemon `karabiner-driverkit` VẪN CÒN** — kanata trên macOS chạy bằng driver VirtualHIDDevice của Karabiner |
| qutebrowser | `home-manager/dotfiles/browser/qutebrowser` | 2026-08-10 | `attic/qutebrowser-2026-08-10` | Dùng brave (macmini) / firefox (airm3, vm, x1g6) |
| aerospace | `home-manager/dotfiles/macos/aerospace` | 2026-08-10 | `attic/aerospace-2026-08-10` | `WindowManager.spoon` của hammerspoon lo toàn bộ window management |
| ansible | `configs/ansible` | 2026-08-10 | `attic/ansible-2026-08-10` | Sửa lần cuối 2025-12-17; `ubuntu.yml` còn cài qutebrowser nên đã tả sai hiện trạng |
| alacritty | `home-manager/dotfiles/terminal/alacritty` | 2026-08-10 | `attic/alacritty-2026-08-10` | Dùng kitty ở mọi host có GUI |
| neofetch2 (overlay) | `overlays/neofetch2` | 2026-08-10 | `attic/neofetch2-2026-08-10` | Comment-out ở macmini từ lâu |
| run-or-raise | `home-manager/dotfiles/run-or-raise` | 2026-08-10 | `attic/run-or-raise-2026-08-10` | Thay bằng beckon. Module vốn **không bật được**: option path lối cũ `modules.dotfiles.*` (thiếu tầng `home-manager`) và nhận special arg `dotfileDir` mà `lib/mkConfigs.nix` không còn cấp |
| fcitx5-macos (overlay) | `overlays/fcitx5-macos` | 2026-08-10 | `attic/fcitx5-macos-2026-08-10` | Thay bằng tongue + flake input `fcitx5-lotus` |
| wayland | `home-manager/environments/wayland` | 2026-08-10 | `attic/wayland-2026-08-10` | Thân rỗng, không làm gì |
| raiseorlaunch (overlay) | `overlays/raiseorlaunch` | 2026-08-09 | — (gỡ trước khi có quy ước tag) | Overlay ghim fork `khanhkhanhlele/raiseorlaunch`, cả repo lẫn tài khoản đều 404 nên không build được; nixpkgs vốn đã có `raiseorlaunch` 2.3.5 nên overlay chỉ đang che mất bản thật |

## Xem lại / khôi phục

Đọc một file mà không đụng cây làm việc:

```sh
git show attic/karabiner-2026-08-10:home-manager/dotfiles/macos/karabiner/default.nix
```

Liệt kê mọi file trong một mục đã gỡ:

```sh
git ls-tree -r --name-only attic/karabiner-2026-08-10 -- home-manager/dotfiles/macos/karabiner
```

Kéo cả thư mục về lại working tree:

```sh
git checkout attic/karabiner-2026-08-10 -- home-manager/dotfiles/macos/karabiner
```

Khôi phục xong **chưa xong**: `mkModule` suy option path từ đường dẫn thư mục, nên
còn phải bật lại ở từng `hosts/*/home.nix` cần nó, rồi chạy `nix eval --impure`
per-host để chắc module không mục trong lúc nằm ngoài cây. Riêng `run-or-raise`
thì phải viết lại theo `mkModule` trước đã — bản trong tag không bật được.

## Không nằm ở đây

Mấy thứ dưới đây **chưa dùng nhưng chưa chết**, vẫn ở nguyên trong cây:

- `home-manager/environments/sway/` — một trong bốn target của
  `configs/shortcuts/apps.*.toml`
- `system-manager/` — chờ máy Linux non-NixOS tiếp theo
- `hosts/termux/` — máy thật đang chạy; `install.sh` được `curl` thẳng từ
  `raw.githubusercontent.com`, vắng mặt trong flake outputs chỉ vì Termux không
  chạy Nix
- `nixos/services/hibernate`, `home-manager/pkgs/ubuntu`,
  `dotfiles/ai/{aichat,gemini,opencode,pi}.d` — tắt có chủ đích
