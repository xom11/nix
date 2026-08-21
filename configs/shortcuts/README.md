# Phim tat focus-or-launch

- `Cap` = `cmd+ctrl+alt` (macOS) / `super+ctrl+alt` (Windows, Linux)
- Engine la `beckon` o ca nam nen tang.
- **MOT file cho ca ba target: `launch-app.toml`** (gop 16/08/2026 tu
  `apps.{linux,macos,windows}.toml`; doi ten tu `apps.shared.toml` 21/08/2026
  de khop voi ten module sinh binding tu no). Bang duoi day khong con cot theo
  OS, vi khong con gi de tach.

Cai lam viec gop kha thi la CHUOI UNG VIEN cua beckon >= 0.9.6:
`"A || B"` thu trai sang phai, cai dau tien hanh dong duoc thi thang. Nho no,
bon dong tung khac nhau theo OS gio la mot dong.

Bang nay sinh tay tu `launch-app.toml` — sua file thi sua ca bang, khong co
gi kiem tra ho.

## `Cap` + phim

| Phim | Gia tri | Ghi chu |
|---|---|---|
| `b` | `Brave Browser \|\| Brave` | ten dau exact tren mac, khong cham catalog |
| `c` | `Claude` | |
| `d` | `Discord` | |
| `f` | `Finder \|\| File Explorer \|\| Files` | ba OS ba ten, khong ten nao chung |
| `g` | `Google Gemini` | |
| `h` | `Facebook` | |
| `j` | `Tao Monitor \|\| https://tao.lenamkhanh.xyz/` | PWA tren Linux mang URL lam Name |
| `k` | `Google Keep \|\| https://keep.google.com/` | nt |
| `m` | `Messenger` | |
| `n` | `Notion` | |
| `s` | `Settings` | khop "System Settings" bang substring tren mac |
| `space` | `kitty \|\| Terminal` | kitty PHAI truoc: "Terminal" exact-match nham Terminal.app cua Apple |
| `t` | `Telegram` | exact ca ba (do 16/08/2026) |
| `y` | `YouTube` | |
| `z` | `Zalo` | **chet tren macOS** — khong cai |

## `Cap` + `Shift` + phim

| Phim | Gia tri | Ghi chu |
|---|---|---|
| `a` | `Apps` | |
| `b` | `Brave Browser \|\| Brave` | |
| `c` | `Google Chrome` | **chet tren Linux** — chua cai tren rog |
| `d` | `DeepSeek` | **khong dang ky duoc tren Windows** — `d` = OneDrive, xem Office key |
| `m` | `Gmail \|\| https://mail.google.com/` | PWA tren Linux mang URL lam Name |
| `v` | `VMware Fusion` | **chet tren Linux/Windows** — chi co tren mac |

### Ba o chet la co y, khong phai bo sot

Gop mot file nghia la mot chord ton tai o moi may, ke ca may khong cai app do.
`beckon check --resolve` se bao do nhung dong ay — do la thong tin dung, khong
phai loi. Do 16/08/2026: **macOS 1 dong** (`Zalo`), **Linux 2 dong**
(`Google Chrome`, `VMware Fusion`). CI chay `beckon check` tran nen khong vo.

`Google Chrome` da chet tren Linux TU TRUOC khi gop — khong phai gia phai tra
cho viec gop.

### Office key: xung dot CHORD, chuoi ung vien khong cuu duoc

Windows giu san `Ctrl+Win+Alt+Shift` + **D L N O P T W X Y Space** cho Office.
`Cap+Shift+d` (DeepSeek) roi dung vao `d` = OneDrive, nen `beckon serve` tren
Windows dang ky that bai va ghi mot dong loi moi lan khoi dong. Chay dung tren
mac va Linux. Muon dung ca ba: doi sang chu ngoai bo do (`e`, `q`, `r`, `u`
con trong o lop nay) — la doi phim tat quen tay nen chua tu doi.

Lop `Cap` tran (3 modifier) khong dinh rang buoc nay, dung thoai mai ca 26 chu.

## Cac lop phim khac (khong sinh tu launch-app.toml)

Hai nhom nay khong di qua launch-app.toml/beckon nen khong nam trong bang
tren. Doc truc tiep o nguon thay vi chep lai o day, de tranh bang tay
bi lech nhu file README cu:

- Lop Tab (`Tab` giu lam modifier): macOS o
  `home-manager/dotfiles/macos/hammerspoon/MySpoons/Tab.spoon/init.lua`,
  sway o `home-manager/environments/sway/sway.d/conf.d/tab.conf`, hyprland o
  `home-manager/environments/hyprland/hypr.d/conf.d/tab.lua`, Windows o
  `home-manager/dotfiles/windows/ahk/tab-key.ahk`.
- Phim quan ly nguon (khoa man/ngu/tat may/khoi dong lai/dang xuat):
  macOS o
  `home-manager/dotfiles/macos/hammerspoon/MySpoons/PowerManager.spoon/init.lua`,
  sway o `home-manager/environments/sway/sway.d/conf.d/system.conf` (muc
  "Power Keybindings"), hyprland o
  `home-manager/environments/hyprland/hypr.d/conf.d/system.lua`, Windows o
  `home-manager/dotfiles/windows/ahk/power-manager.ahk`, GNOME dung
  keybinding co san cua desktop, khai o
  `home-manager/environments/gnome/shortcuts.nix`.
