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
| qutebrowser | `home-manager/dotfiles/browser/qutebrowser` | 2026-08-10 | `attic/qutebrowser-2026-08-10` | Dùng brave (macmini). airm3/vm/x1g6 hồi đó dùng firefox — nay firefox cũng đã gỡ, xem dòng dưới |
| **vscode** | `home-manager/dotfiles/vscode` | 2026-08-10 | `attic/vscode-2026-08-10` | Thôi quản `settings.json` + `keybindings.json`. **Ứng dụng VSCode vẫn còn** (`pkgs/nixos`, winget trên a14) — chỉ phần config là thủ công từ nay. Windows từng symlink từ đây qua `links.ps1`, đã gỡ cùng đợt |
| **firefox** | `home-manager/dotfiles/browser/firefox` | 2026-08-10 | `attic/firefox-2026-08-10` | Gỡ **sạch khỏi mọi máy**, không chỉ module: cask `firefox` (nix-darwin/brew), `programs.firefox.enable` (nixos/base), và phím `Cap+Shift+f` ở cả 4 file `apps.*.toml` |
| **wezterm** | `home-manager/dotfiles/terminal/wezterm` | 2026-08-10 | `attic/wezterm-2026-08-10` | Chỉ Windows dùng, không có `default.nix`. Gỡ cả gói winget `wez.wezterm` khỏi module **và** khỏi a14 |
| keyd (nixos) | `nixos/services/keyd` | 2026-08-10 | `attic/keyd-nixos-2026-08-10` | x1g6 chuyển sang kanata — một engine dùng chung `configs/kanata` với macmini/airm3/vm/a14-win. **`system-manager/services/keyd` là module KHÁC, vẫn còn** |
| hibernate | `nixos/services/hibernate` | 2026-08-10 | `attic/hibernate-2026-08-10` | Không host nào bật. Phím tắt `systemctl hibernate` trong i3wm/sway gọi thẳng systemd, không liên quan, vẫn còn |
| vimiumc | `home-manager/dotfiles/browser/vimiumc` | 2026-08-10 | `attic/vimiumc-2026-08-10` | File mồ côi, không có `default.nix`. surfingkeys đã thay |
| tampermonkey | `home-manager/dotfiles/browser/tampermonkey` | 2026-08-10 | `attic/tampermonkey-2026-08-10` | File mồ côi, không có `default.nix` |
| `hosts/.ignore` | `hosts/.ignore` | 2026-08-10 | `attic/hosts-ignore-2026-08-10` | File rỗng còn tracked nhưng đã không còn trên đĩa |
| aerospace | `home-manager/dotfiles/macos/aerospace` | 2026-08-10 | `attic/aerospace-2026-08-10` | `WindowManager.spoon` của hammerspoon lo toàn bộ window management |
| ansible | `configs/ansible` | 2026-08-10 | `attic/ansible-2026-08-10` | Sửa lần cuối 2025-12-17; `ubuntu.yml` còn cài qutebrowser nên đã tả sai hiện trạng |
| alacritty | `home-manager/dotfiles/terminal/alacritty` | 2026-08-10 | `attic/alacritty-2026-08-10` | Dùng kitty ở mọi host có GUI |
| neofetch2 (overlay) | `overlays/neofetch2` | 2026-08-10 | `attic/neofetch2-2026-08-10` | Comment-out ở macmini từ lâu |
| run-or-raise | `home-manager/dotfiles/run-or-raise` | 2026-08-10 | `attic/run-or-raise-2026-08-10` | Thay bằng beckon. Module vốn **không bật được**: option path lối cũ `modules.dotfiles.*` (thiếu tầng `home-manager`) và nhận special arg `dotfileDir` mà `lib/mkConfigs.nix` không còn cấp |
| fcitx5-macos (overlay) | `overlays/fcitx5-macos` | 2026-08-10 | `attic/fcitx5-macos-2026-08-10` | Thay bằng tongue + flake input `fcitx5-lotus` |
| wayland | `home-manager/environments/wayland` | 2026-08-10 | `attic/wayland-2026-08-10` | Thân rỗng, không làm gì |
| raiseorlaunch (overlay) | `overlays/raiseorlaunch` | 2026-08-09 | — (gỡ trước khi có quy ước tag) | Overlay ghim fork `khanhkhanhlele/raiseorlaunch`, cả repo lẫn tài khoản đều 404 nên không build được; nixpkgs vốn đã có `raiseorlaunch` 2.3.5 nên overlay chỉ đang che mất bản thật |
| sway/nixos (module con) | `home-manager/environments/sway/nixos` | 2026-08-14 | `attic/sway-submodules-2026-08-14` | Ban trung lap cu cua module cha, khong host nao bat. Tro duong dan tuong doi vao `kanshi.d` — thu muc da chuyen sang `environments/wayland` |
| sway/ubuntu (module con) | `home-manager/environments/sway/ubuntu` | 2026-08-14 | `attic/sway-submodules-2026-08-14` | Cai sway qua `nix-apt` cho host Ubuntu; `desktop` dung i3wm, khong host nao bat. Tro vao `swaylock.d` da chuyen di |

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
- `system-manager/` — chờ máy Linux non-NixOS tiếp theo. **`system-manager/services/keyd`
  vẫn còn** dù `nixos/services/keyd` đã gỡ; hai module khác nhau
- `hosts/termux/` — máy thật đang chạy; `install.sh` được `curl` thẳng từ
  `raw.githubusercontent.com`, vắng mặt trong flake outputs chỉ vì Termux không
  chạy Nix
- `home-manager/dotfiles/browser/surfingkeys/` — không có `default.nix` nhưng
  **không** mồ côi: extension tự tải `configs.js` bằng URL raw trên GitHub, nên
  file phải nằm trong repo
- `home-manager/pkgs/ubuntu`, `dotfiles/ai/{aichat,gemini,opencode,pi}.d` —
  tắt có chủ đích

## Đã gỡ khỏi máy thật, không chỉ khỏi repo

Hai thứ dưới đây gỡ khỏi repo là chưa đủ, nên đã xử lý ngay trên máy:

- **wezterm trên a14** — `winget uninstall wez.wezterm` (thành công), xoá
  symlink `~\.config\wezterm\wezterm.lua` và thư mục chứa nó.
- **symlink VSCode trên a14** — `settings.json` và `keybindings.json` dưới
  `%APPDATA%\Code\User\` đã chuyển từ symlink thành **file thật giữ nguyên nội
  dung**, chứ không xoá. Nếu để nguyên, chúng sẽ đứt ngay khi a14 pull và VSCode
  mất sạch cấu hình. Từ nay hai file đó là thủ công.
