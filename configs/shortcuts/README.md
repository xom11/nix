# Phim tat focus-or-launch

- `Cap` = `cmd+ctrl+alt` (macOS) / `super+ctrl+alt` (Windows, Linux)
- Engine la `beckon` o ca bon nen tang.

## `Cap` + phim

| Phim | macOS | Windows | GNOME | sway |
|---|---|---|---|---|
| `b` | Brave | Brave | Brave | brave |
| `c` | Claude | Claude | Claude | Claude |
| `d` | Discord | Discord | Discord | Discord |
| `f` | Finder | File Explorer | -- | -- |
| `g` | Google Gemini | Google Gemini | Google Gemini | Gemini |
| `h` | Facebook | Facebook | Facebook | Facebook |
| `j` | Tao Monitor | Tao Monitor | Tao Monitor | Tao Monitor |
| `k` | Google Keep | Google Keep | Google Keep | Google Keep |
| `m` | Messenger | Messenger | Messenger | Messenger |
| `n` | Notion | Notion | Notion | Notion |
| `s` | Settings | Settings | Settings | -- |
| `space` | kitty | Terminal | kitty | kitty |
| `t` | Telegram | Telegram | Telegram Web | Telegram Web |
| `y` | YouTube | YouTube | YouTube | YouTube |
| `z` | -- | Zalo | Zalo | -- |

## `Cap` + `Shift` + phim

| Phim | macOS | Windows | GNOME | sway |
|---|---|---|---|---|
| `a` | Apps | -- | -- | -- |
| `b` | Brave | Brave | Brave | brave |
| `c` | Google Chrome | Google Chrome | Google Chrome | Google Chrome |
| `d` | DeepSeek | DeepSeek | DeepSeek | DeepSeek |
| `f` | Firefox | Firefox | Firefox | Firefox |
| `m` | Gmail | Gmail | Gmail | Gmail |
| `v` | VMware Fusion | -- | -- | -- |

## Cac lop phim khac (khong sinh tu apps.*.toml)

Hai nhom nay khong di qua apps.*.toml/beckon nen khong nam trong bang
tren. Doc truc tiep o nguon thay vi chep lai o day, de tranh bang tay
bi lech nhu file README cu:

- Lop Tab (`Tab` giu lam modifier): macOS o
  `home-manager/dotfiles/macos/hammerspoon/MySpoons/Tab.spoon/init.lua`,
  sway o `home-manager/environments/sway/sway.d/conf.d/tab.conf`, Windows o
  `home-manager/dotfiles/windows/ahk/tab-key.ahk`.
- Phim quan ly nguon (khoa man/ngu/tat may/khoi dong lai/dang xuat):
  macOS o
  `home-manager/dotfiles/macos/hammerspoon/MySpoons/PowerManager.spoon/init.lua`,
  sway o `home-manager/environments/sway/sway.d/conf.d/system.conf` (muc
  "Power Keybindings"), Windows o
  `home-manager/dotfiles/windows/ahk/power-manager.ahk`, GNOME dung
  keybinding co san cua desktop, khai o
  `home-manager/environments/gnome/shortcuts.nix`.

