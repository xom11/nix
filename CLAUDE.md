# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## This repo is public

`xom11/nix` on GitHub, visibility **PUBLIC**. Git history is permanent — deleting
something in a later commit does not unpublish it. Every write here is a publish,
and that includes commit messages, code comments, docs, and PR/issue text.

Never commit:

- **Credentials** — keys, tokens, passwords, session cookies. `.age` files are
  ciphertext and belong here; whatever they decrypt to does not.
- **Private identifiers** — serial numbers, personal email or phone, LAN
  addresses (`192.168.*`, `10.*`), paths that expose who or where someone is.

  **Tailscale addresses are the deliberate exception.** `100.64.0.0/10` is
  CGNAT space: an address there routes only inside this tailnet, and reaching
  it needs a device the owner admitted plus a key they issued. Publishing one
  gives a reader a name, not a way in. So `home-manager/programs/ssh/config`
  carries every host's real `HostName` and `User` in plaintext **on purpose**,
  and `.githooks/allow-vars` exempts `ROUTER_ENDPOINT` for the same reason.
  Do not "fix" either one, and do not re-raise it as a finding — this was
  decided knowingly. What it does publish is the machine inventory: how many
  hosts exist, their names, and which user runs them. That is accepted.

  The exception is exactly this and nothing wider. A **public** address, a
  port-forward, or a tailnet address written next to a credential or an
  `authorized_keys` entry is still a leak.
- **Real values in examples.** Commands, comments and docs use placeholders
  (`$TOKEN`, `user@host`), never a working credential — not even an expired one.
- **Unredacted machine output** — logs, `env` dumps, error traces, screenshots.
  Capture is not review; read it before pasting it in.
- **Shell metacharacters inside secret values.** `apikey.zsh.age` is read by zsh
  *and* by a deliberately simple PowerShell parser on Windows, and the two
  disagree. `$`, a backtick or `$(...)` expands on one side and stays literal on
  the other. Quotes diverge too: zsh concatenates adjacent quoted words, so
  `"say ""hi"""` is `say hi` and `'it'\''s'` is `it's`, while the Windows parser
  strips only the outer pair and keeps the rest verbatim. Either way one machine
  gets the real value and the other a corrupted one, with nothing to warn you.
  Values are literal text containing none of `$`, backtick, `$(...)`, `'`, `"`.

- **Measurements taken from live secrets.** Counts, value lengths, character
  inventories, "all 14 comply" — these describe real secret material and are as
  publishable as the values themselves. Verify against live data all you like;
  write only the verdict, never the numbers. This rule exists because a design
  doc here once published the character set of every real API key.

**`docs/` is a public website, not just files.** `.github/workflows/docs.yml`
runs `mkdocs build` on every push to `main`, and `mkdocs.yml` has no `nav:` — so
**every** `.md` under `docs/` is deployed to `xom11.github.io/nix` and indexed
for search, whether or not anything links to it. A file being "just notes" is not
a defence. `docs/superpowers/` is gitignored for exactly this reason: AI-written
specs and plans quote whatever was measured while verifying, and that is usually
live data.

Secrets in this repo decrypt to paths *outside* the tree (`~/.ssh/age.d/`,
`~/.config/zsh/apikey.zsh`). Keep it that way — never write plaintext under `~/.nix`.

Read `git diff --cached` before committing; a glob check is not enough. If a
credential does land in a commit, **rotate it** — the push is already public, so
rewriting history alone does not fix anything.

### The guards, and what each one cannot see

Four layers, deliberately non-overlapping. Knowing the gap in each is the point —
a guard you trust past its range is worse than none.

| Guard | Where | Sees | Blind to |
|---|---|---|---|
| `.githooks/pre-push` | your machine, at push | values that **are** in `apikey.zsh`, in **every commit** of the range | a key not in `apikey.zsh` yet |
| `.github/scripts/check-placeholders.sh` | CI | credential fields under `home-manager/dotfiles/` that hold a literal | anything outside that tree; deleted-before-push |
| `gitleaks` + `.gitleaks.toml` | CI | known patterns in the pushed range | whatever no pattern describes — it missed the real key here |
| GitHub push protection | GitHub | partner patterns | self-issued keys; a public repo gets no `non_provider_patterns` |

The hook compares **exactly** against decrypted secrets — no entropy guessing —
and reads `git log -p --cc` per commit, never `git diff`: adding then deleting
before a push leaves a clean overall diff and a permanent commit. It prints only
variable **names**. Bypass one push with `git push --no-verify`.

Inside a diff it reads **added lines only**. A `-` line means the value is in an
earlier commit — either inside the range, where its `+` was already caught, or
outside it, where it is already pushed. Blocking there would only block the
cleanup commit. `.githooks/allow-vars` exempts variables whose value is
deliberately public (`ROUTER_ENDPOINT` is a Tailscale address). Prefer adding a
name there over reaching for `--no-verify`, which drops the whole fence.

It gets its values from `~/.config/zsh/apikey.zsh`, the Windows `apikey.ps1`, and
by decrypting `age.d/apikey.zsh.age` in memory. If it finds none, it blocks only
when this machine's key is in `programs/ssh/authorized_keys` — a machine that is
supposed to decrypt and cannot is a broken fence, not a clean repo. On the other
eight hosts it says so and steps aside.

`core.hooksPath` is set by `home.activation` (nix) and
`windows/modules/programs/githooks` (Windows), so a rebuild installs it. It must
stay **absolute**: git resolves a relative `core.hooksPath` against the current
directory, so `git push` from a subdirectory would silently run no hook.

Run any of them by hand: `./.githooks/…` via `.github/scripts/test-prepush.sh`,
`./.github/scripts/check-placeholders.sh [--self-test]`.

## Rebuild Commands

`--impure` is required everywhere: `lib/mkConfigs.nix` reads `$USER`/`$SUDO_USER`
and `builtins.currentSystem` at eval time.

```bash
# macOS (nix-darwin) — also available as shell alias `update`
sudo darwin-rebuild switch --impure --flake ~/.nix#macmini
sudo darwin-rebuild switch --impure --flake ~/.nix#airm3

# NixOS
sudo nixos-rebuild switch --impure --flake ~/.nix#x1g6
sudo nixos-rebuild switch --impure --flake ~/.nix#vm
sudo nixos-rebuild switch --impure --flake ~/.nix#rog

# Standalone home-manager
home-manager switch --impure -b backup --flake ~/.nix#server     # also: desktop, minimal

# system-manager (system-level config on a non-NixOS Linux distro)
sudo nix run 'github:numtide/system-manager' -- switch --flake ~/.nix#desktop
```

## Checking a host without rebuilding it

`--system` overrides `builtins.currentSystem`, so any host can be evaluated from
any machine. This is what CI does (`.github/workflows/eval.yml`), and it is the
fastest way to know whether a change breaks a host you are not sitting at:

```bash
nix eval --impure --system x86_64-linux  .#homeConfigurations.desktop.activationPackage.drvPath
nix eval --impure --system aarch64-linux .#nixosConfigurations.vm.config.system.build.toplevel.drvPath
nix eval --impure                        .#darwinConfigurations.macmini.system.drvPath
```

`nix flake check` does **not** work here — it evaluates purely and dies on
`builtins.currentSystem`. Use the per-host `nix eval --impure` above instead.

`nix fmt` (alejandra) and `nix develop` (alejandra, nixd, deadnix, statix) are wired up.

## Kiểm trên chính máy đó — ba cách nói dối quen thuộc

Ba thứ dưới đây đều trả lời **sai mà nghe hợp lý**, nên không ai nghĩ tới việc kiểm
chéo. Cả ba đã làm hai phiên làm việc độc lập cùng kết luận ngược trong một buổi.

- **Đừng kết luận "tiến trình X không chạy" bằng `pgrep -x` / `ps -eo comm`.**
  nixpkgs bọc binary thành `.NAME-wrapped`, mà `comm` cắt ở **15 ký tự** →
  `.Hyprland-wrapp`. Và bẫy **không đồng đều giữa các gói**: cùng máy, cùng lớp
  `programs.*`, Hyprland ra `.Hyprland-wrapp` còn sway ra `sway` (wrapper `exec`
  sang bản unwrapped rồi tự thay thế mình). Nên không suy được từ gói này sang gói
  kia — kiểm từng cái bằng `readlink -f` + xem thư mục `bin`, hoặc khớp
  `grep -E "(^| )\.?NAME(-wrapp)?"`, hoặc nhìn `args` thay vì `comm`.
- **`pgrep -f <ten>` thì sai ngược lại**: nó khớp cả dòng lệnh của chính bạn. Một
  vòng `for` kiểm 7 dịch vụ cho 7 dương tính giả liền.
- **`sway --validate` trần qua SSH là XANH GIẢ** — nó dựng backend DRM trước khi
  đọc config nên chết ở `Could not open target tty`, và bản sạch với bản hỏng cho
  output y hệt. Phải `WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 sway --validate`,
  và **mã thoát luôn 0 kể cả khi hỏng** → phải đọc output. `Hyprland --verify-config`
  thì ngược lại: chạy thẳng qua SSH, in `config ok`, và có đi theo `source`.

Hệ quả rộng hơn, đúng cho cả `nix eval`: khi viết một kết luận dạng *"A thế nào thì
B cũng thế"* mà chỉ đo A — dừng lại và đo B. Riêng repo này đã dính ba lần, và cả
ba đều là hai thứ **cùng một họ** (32-bit→64-bit, GNOME→stack khác, Hyprland→sway),
tức đúng chỗ cảm giác "chắc giống nhau" mạnh nhất.

## Công cụ tách repo riêng (org `xom11`) — sửa ở thượng nguồn

Một phần hành vi của repo này KHÔNG nằm trong cây này. Năm công cụ tự viết đã
tách thành repo riêng dưới org `xom11`, repo này chỉ ghim và gọi chúng. Khi phím
tắt không mở app, PWA không cài, bộ gõ nhảy sai — câu hỏi đầu tiên là *lỗi ở lớp
tích hợp trong repo này hay ở chính công cụ?* Nếu ở công cụ thì sửa BÊN ĐÓ, phát
hành, rồi bump pin ở đây. Đừng vá vòng bằng một lớp workaround trong repo này:
công cụ còn được dùng ở chỗ khác (Windows, máy khác), và bản vá vòng chỉ chữa
đúng một điểm gọi.

| Công cụ | Là gì | Đường vào repo này | Clone làm việc |
|---|---|---|---|
| [`beckon`](https://github.com/xom11/beckon) | focus-or-launch app switcher (mac/Win/Linux) | flake input + overlay → `pkgs.beckon`; `serve` đọc `configs/shortcuts/apps.shared.toml`; module `home-manager/programs/beckon-serve` | `~/Documents/dev/beckon` |
| [`dotbrave`](https://github.com/xom11/dotbrave) | quản Brave bằng một file TOML | flake input + overlay → `pkgs.dotbrave` trong `home.packages`. **Không còn module Nix nào** (gỡ 16/08/2026) — chạy tay, xem mục "dotbrave: config trong repo, apply hoàn toàn bằng tay" bên dưới | `~/Documents/dev/dotbrave` |
| [`tongue`](https://github.com/xom11/tongue) | chuyển chế độ gõ vi/en/zh, lái cả layout OS lẫn bộ gõ ngoài | flake input + overlay → `pkgs.tongue`, **chỉ có trên darwin** (x1g6/vm cố ý không có) | `~/Documents/dev/tongue` |
| [`tongue.nvim`](https://github.com/xom11/tongue.nvim) | ép tiếng Anh ở Normal mode | `vim.pack.add` trong `home-manager/programs/nvim/lua/plugins/tongue.lua`, rev ghim ở `nvim-pack-lock.json` | `~/Documents/dev/tongue.nvim` |
| [`nix-apt`](https://github.com/xom11/nix-apt) | apt khai báo trên Debian/Ubuntu | flake input → `homeManagerModules.default` (nối trong `lib/mkConfigs.nix`), dùng qua `services.nix-apt` | chưa clone |

`dotbrowser` (tiền thân của `dotbrave`) **không** được repo này dùng — đừng
tưởng nó là đường vào thứ hai.

`dotpkg` thì khác, và đừng đọc nó theo khuôn của bốn cái trên: nó **không** là
flake input và **không** có overlay. Một cái flake đã được thêm rồi gỡ trong
cùng ngày 2026-08-12 — `pkgs.dotpkg` trên mac hay NixOS là một binary không có
gì để quản, vì thứ nó quản là winget và scoop.

Từ 2026-08-12 nó là **thứ duy nhất cài gói trên Windows**: `packages.scoop` và
`packages.winget` đã bị xoá, `windows/modules/packages/dotpkg/module.ps1` gọi
`dotpkg apply` thay cả hai. Hai file trong repo là nguồn chân lý:

- `home-manager/dotfiles/windows/dotpkg/pkg.toml` — khai báo
- `home-manager/dotfiles/windows/dotpkg/pkg.lock` — pin, **có commit**, cùng vai
  `flake.lock`. `state.json` và `pkg.lock.bak` thì gitignore: cái đầu là thứ
  dotpkg SỞ HỮU trên một máy, cái sau là rác dotpkg tự để lại.

**Không file nào được symlink sang `%USERPROFILE%`, và đó là kết luận từ đo đạc
chứ không phải sở thích.** dotpkg ghi lock bằng `File::create` + `fs::rename`, mà
rename **thay symlink bằng file thật**: link đứt ngay lần `dotpkg update` đầu,
pin mới rơi vào bản ở thư mục nhà, repo im lặng ngừng nhận, `git status` sạch
suốt. Module truyền `--config`/`--lock` trỏ thẳng vào repo; muốn gõ tay thì `cd`
vào `home-manager/dotfiles/windows/dotpkg` rồi chạy `dotpkg` trần.
Luật rộng hơn rút ra từ đây: **file nào một công cụ GHI LẠI thì đừng để sau
symlink vào repo, trừ khi đã ĐO là nó ghi đè tại chỗ** (`vim.pack` đã đo và đạt,
xem `nvim-pack-lock.json`; dotpkg đã đo và trượt).

**"Ghi đè tại chỗ" là điều kiện CẦN chứ chưa đủ** — fcitx5 dạy ra vế thiếu.
`i18n/fcitx5.d/{config,profile}` được symlink ra `~/.config/fcitx5/`, và fcitx5 ghi
đè tại chỗ (symlink sống nguyên) nên theo câu trên nó *đạt*. Nhưng nó giữ state
trong bộ nhớ và ghi ra lúc thoát, nên sửa file trong repo khi nó đang chạy là bị
đè mất — `git checkout --` dọn xong bẩn lại ngay. Vế thứ hai: **công cụ đó không
được giữ bản sao trong bộ nhớ rồi ghi lại theo lịch của nó.** Muốn sửa tay thì dừng
fcitx5 trước. Dấu nhận biết: nó luôn thêm đúng một dòng trống cuối file.

Ba điều nữa, cả ba đều im lặng khi sai:

- **`apply.ps1` đặt `$ErrorActionPreference = 'Stop'`, và thân module chạy dưới
  preference của CALLER** (nó là scriptblock gọi bằng `&`). PowerShell 5.1 biến
  stderr của lệnh ngoài thành lỗi kết thúc, mà dotpkg in cảnh báo ra stderr —
  module chết trước khi đọc được mã thoát. Phải hạ về `Continue` quanh lời gọi.
- **Exit 1 là trạng thái bình thường, không phải lỗi.** dotpkg định nghĩa 1 là
  "outstanding", gộp cả gói bị bỏ qua vì tiến trình đang chạy — mà python,
  beckon, kanata thì gần như luôn chạy. Module cảnh báo ở 1, chỉ throw từ 2.
- **Đừng khai báo app tự cập nhật trong `[winget]`.** dotpkg chỉ có
  `pin = "version-only"`, không có kiểu "chỉ cần có mặt", nên Brave/Vivaldi/
  Chrome/Discord/Warp luôn vượt pin → từ chối downgrade → đỏ vĩnh viễn. Chúng cố
  ý nằm ngoài và vẫn là `unmanaged`.

Binary dotpkg vẫn tải tay từ GitHub Release, repo này không ghim phiên bản **của
chính công cụ** — nhưng có ghim phiên bản **của các gói nó cài**, qua `pkg.lock`.

**Sàn phiên bản là `0.2.0`, và nó được gác.** Ba thứ upstream sửa theo đúng
báo cáo từ lần tích hợp này — so sánh version có số 0 đuôi,
`[winget.opts] pin = "none"`, và **exit 3** — đều nằm trong v0.2.0 (13/08/2026).
`pkg.toml` đang dùng cả hai surface mới, nên máy chạy binary cũ hơn sẽ **hỏng
toàn phần chứ không hỏng một phần**: 0.1.0 gặp `[winget.opts]` là từ chối cả
file (`unknown field 'opts', expected 'packages' or 'guard'`) và mọi gói thành
unmanaged. `windows/modules/packages/dotpkg/module.ps1` kiểm `dotpkg --version`
trước khi chạy và đỏ kèm hướng dẫn nếu thấp hơn.

Gác được là nhờ v0.2.0 bump version: trước đó build từ main cũng báo `0.1.0` y
hệt bản phát hành, nên không consumer nào phân biệt nổi hai bản.

Thứ tự khi lên phiên bản mới vẫn không đổi: **phát hành → cài binary lên mọi máy
Windows → rồi mới sửa `pkg.toml`.** Đảo lại là a14 đỏ ngay lần `apply.ps1` kế
tiếp, và lần này nó đỏ ở gate chứ không đỏ mù mờ.

**Binary đến từ scoop, và dotpkg tự khai báo chính nó.** Từ 13/08/2026
`xom11/scoop-bucket` có manifest cho dotpkg, nên `pkg.toml` khai `"dotpkg"` như
mọi gói khác và phiên bản được ghim bằng commit bucket trong `pkg.lock` — không
còn bước tải tay nào. Module bootstrap bằng `scoop bucket add` + `scoop install
xom11/dotpkg` khi PATH chưa có gì, nên máy trắng vẫn dựng được bằng một lệnh.

Hai điều đã đo, cả hai đều im lặng khi vi phạm:

- **dotpkg KHÔNG tự nâng cấp được chính nó.** Ép bằng một lock ghi version cũ
  hơn trên a14: `! scoop dotpkg running -- stop it first`. Hàng rào "tiến trình
  đang chạy" bắt trúng chính nó — đúng, vì Windows không cho ghi đè `.exe` đang
  chạy. Nên khi có bản mới, `apply` **báo held chứ không nâng**, và cả run thoát
  3 (lành tính). Nâng bằng `scoop update dotpkg` lúc nó không chạy.
- **Một bản cũ nằm sớm hơn trong PATH sẽ che bản scoop.** Đo được:
  `%USERPROFILE%\.local\bin` đứng **trước** `scoop\shims`, và bản cài tay ở đó
  đã che shim cho tới khi bị xoá. Đây đúng là bệnh `stylua.exe` vẫn đang mắc
  trên máy đó. Gate `dotpkg --version` trong module là thứ bắt được chuyện này;
  không có nó thì triệu chứng là `dotpkg update` cần mẫn nâng cấp một binary
  không ai chạy.

### Mỗi công cụ có nhiều hơn một cái pin, và chúng không tự đồng bộ

Đây là chỗ dễ mất buổi chiều nhất: sửa xong upstream, bump một chỗ, thấy mac hết
lỗi còn a14 vẫn lỗi y nguyên — không phải bug thứ hai, mà là kênh chưa bump.

| Kênh | Ghim ở đâu | Bump bằng |
|---|---|---|
| Máy Nix (mac/NixOS/HM) | `flake.lock` | `nix flake update beckon` (input theo nhánh mặc định, không ghim tag) rồi rebuild |
| Windows — beckon | manifest trong **repo thứ ba** `xom11/scoop-bucket`; khai báo ở `pkg.toml`, và version bị ghim theo **commit của bucket** trong `pkg.lock` | release beckon → sửa manifest bên scoop-bucket → `dotpkg update` → **commit diff của `pkg.lock`**. `scoop update` một mình không đủ nữa: dotpkg sẽ kéo ngược về đúng commit đã ghim |
| Windows — dotbrave | chuỗi `dotbrave==<ver>` trong `windows/modules/programs/dotbrave/module.ps1` | publish PyPI → sửa tay chuỗi đó (cố ý ghim: script chạy Administrator và ghi HKLM policy) |
| Windows — tongue | `%USERPROFILE%\.local\bin\tongue.exe`, cài **ngoài luồng** — `apply.ps1` lẫn scoop đều không cài | copy tay binary mới lên máy |
| nvim plugin | rev trong `nvim-pack-lock.json` (symlink out-of-store, `vim.pack` GHI thẳng vào working tree) | update plugin trong nvim → commit diff của lock |
| GNOME | extension `beckon@xom11.github.io` cài tay trên máy (Wayland: Mutter chặn focus từ ngoài) | cài lại tay; nhớ `disable-user-extensions = false` |
| CI job `shortcuts` | rev đọc lại **từ `flake.lock`** trong `.github/workflows/eval.yml` | theo flake.lock |
| Windows — dotpkg (bản thân binary) | `pkg.lock`, y như mọi gói scoop khác: nó **tự khai báo chính nó** và đến từ bucket `xom11` | phát hành → sửa manifest bên scoop-bucket → `dotpkg update` → commit lock. **Rồi `scoop update dotpkg` bằng tay**, vì nó không tự nâng được chính nó (xem dưới) |
| Windows — các gói dotpkg cài | `home-manager/dotfiles/windows/dotpkg/pkg.lock`, **có commit** | `dotpkg update` trong thư mục đó, rồi commit diff của lock |

Hệ quả của dòng cuối: nếu bản sửa beckon đổi cú pháp `apps.shared.toml`, phải
bump `flake.lock` **cùng commit** với file TOML mới — không thì `beckon check`
của CI chạy bằng binary cũ và đỏ (hoặc tệ hơn: xanh giả theo chiều ngược lại).

**Và `flake.lock` chỉ lo được máy Nix.** Cú pháp mới còn phải tới a14 qua
`pkg.lock`, kênh hoàn toàn khác — bump một cái mà quên cái kia thì mac xanh còn
Windows chết lặng. Đã xảy ra 19/08/2026 với cú pháp `||`: `flake.lock` ở 0.9.8
(đủ), `pkg.lock` còn ghim 0.9.2, và binary thật trên a14 lại là 0.9.6 vì ai đó
`scoop update` bằng tay. **Ba con số, ba ngả, `git status` sạch trơn** — và
`dotpkg apply` lúc đó sẽ kéo LÙI máy về 0.9.2 chứ không cứu. Khi một máy Windows
hành xử sai, so đủ ba chỗ trước khi đoán bất cứ điều gì khác.

Quy tắc đó rộng hơn TOML: nó áp cho **mọi** thay đổi beckon mà repo này gọi
tới, kể cả bề mặt CLI. beckon 0.6.0 đổi cờ thành subcommand (`--serve` →
`serve`, `--check` → `check`, `-L` → `installed`, `-d` → `doctor`) và không
giữ alias nào. Ba chỗ THỰC THI mang cú pháp đó — launchd agent
(`home-manager/programs/beckon-serve/default.nix`), hai scheduled task
(`windows/modules/services/beckon-serve{,-watchdog}`) — nên bump `flake.lock`
mà quên chúng, hoặc sửa chúng mà quên bump, đều làm phím tắt chết. Trên
Windows còn chết **âm thầm**: stderr đi vào `--log`, dấu hiệu duy nhất là
tray icon biến mất, và watchdog restart 5 phút một lần mãi mãi.

**Cap binary+plist KHONG nguyen tu luc activation — do duoc 10/08/2026 tren
macmini. TREN macOS CUA SO NAY DA BI XOA cung ngay; muc nay giu lai vi Windows
van dinh nguyen.** home-manager chep binary moi vao `~/.local/libexec/beckon`
TRUOC khi ghi lai plist, nen launchd con giu plist cu da chay `beckon --serve`
vao binary 0.6.0. `serve.log` ghi lai dung khoanh khac do:

```
error: unexpected argument '--serve' found
Usage: beckon [OPTIONS] <ID>
beckon serve: 20 shortcuts registered from .../apps.macos.toml
```

macOS het dinh vi khong con buoc chep: agent tro THANG vao store path, nen
binary va plist la cung mot thu va doi cung mot luc. Do la he qua phu cua viec
bo grant Accessibility (xem `home-manager/programs/beckon-serve/README.md`) —
neu ngay nao khoi phuc lai ban copy o `~/.local/libexec`, cua so nay quay lai
y nguyen.

Ngay ca truoc do macOS cung tu lanh vi `setupLaunchAgents` chay ngay sau va
KeepAlive dung day len. Tren Windows thi KHONG: giua `scoop update beckon` va
`apply.ps1` khong co ai dung day, watchdog 5 phut/lan cung fail, va stderr di
vao `--log` nen khong ai thay. Vi vay tren a14 phai lam theo thu tu khac:

1. `Disable-ScheduledTask` ca BeckonServe lan BeckonServeWatchdog
2. `Get-Process beckon | Stop-Process -Force` -- `Stop-ScheduledTask` mot
   minh KHONG du: no dung task chu khong giet tien trinh chau, va scoop tu
   choi ghi de khi binary con dang chay
3. `scoop update beckon`
4. chay lai hai module (dang ky lai task)
5. `Enable-ScheduledTask` + `Start-ScheduledTask`

Cua so hong bang khong. Con `apply.ps1` khong co bo loc module (`$modules`
hardcode), nen chay rieng hai module beckon bang cach dung lai dung `$Ctx`
cua no thay vi reconcile ca may.

### Thử bản sửa chưa phát hành: `--override-input`

Trỏ input sang clone local, không cần commit lên GitHub, không cần đụng
`flake.lock`:

```bash
nix eval --impure --raw \
  --override-input beckon "git+file://$HOME/Documents/dev/beckon" \
  ~/.nix#darwinConfigurations.macmini.pkgs.beckon.drvPath
```

drvPath đổi = bản local đã vào. Áp thật thì thêm đúng cờ đó vào
`darwin-rebuild switch` / `nixos-rebuild switch` / `home-manager switch`.

Bốn điều đã đo trên máy (09/08/2026), cả bốn đều im lặng khi sai:

- **`path:...` chết**, không phải `git+file://`. `path:` copy cả thư mục nên gặp
  `.codegraph/daemon.sock` là dừng: `error: file '…/daemon.sock' has an
  unsupported type`. Lỗi đọc như hỏng flake chứ không như "chọn sai lược đồ".
- **Sửa file đã tracked mà chưa commit thì VÀO.** nix in
  `→ 'git+file:///…'` (không kèm `rev=`) và drvPath đổi.
- **File chưa `git add` thì KHÔNG vào.** nix vẫn coi cây là sạch, resolve ra
  `?ref=…&rev=…` và trả về drvPath y hệt bản đang ghim — nghĩa là "sửa rồi mà
  không thấy gì đổi" gần như luôn là file mới chưa add. `git add -N` là đủ.
- **Phải ghi rõ `~/.nix#…`.** Chạy lệnh khi đang đứng trong repo công cụ thì
  `.#` trỏ vào flake của công cụ đó; nix báo `does not provide attribute` kèm
  `warning: … override for a non-existent input 'beckon'` — hai thông điệp
  không hề gợi ra rằng mình gọi nhầm flake.

## Architecture

### Flake outputs

`flake.nix` defines outputs via thin wrappers in `lib/mkConfigs.nix`:

| Builder | Outputs |
|---|---|
| `lib.mkDarwin` | `darwinConfigurations.{macmini,airm3}` |
| `lib.mkNixos` | `nixosConfigurations.{x1g6,vm,rog}` |
| `lib.mkHomeManager` | `homeConfigurations.{server,desktop,minimal}` |
| `lib.mkSystemManager` | `systemConfigs.<system>.{desktop}` — keyed by system (`aarch64-linux`, `x86_64-linux`) |

`mkDarwin`/`mkNixos` wire home-manager in as a module (`useGlobalPkgs = true`, so
home-manager reuses the system `pkgs` rather than instantiating nixpkgs twice).
`mkHomeManager` builds its own `pkgs`. All four apply the same overlay list
(`allOverlays` = `overlays/` + the overlays shipped by flake inputs), so
`pkgs.<tool>` resolves identically under every builder.

Each builder wires `hosts/{device}/configuration.nix` and/or `hosts/{device}/home.nix`.
Standalone home-manager hosts have only `home.nix`.

### Special args

All modules receive these extra args (defined in `lib/mkConfigs.nix`):

- `device` — string name of the current host
- `username` — detected from `$SUDO_USER`/`$USER` at eval time, falls back to `"kln"`
- `homeDir` — `/Users/$username` on darwin, `/home/$username` on linux
- `repoPath` — always `$homeDir/.nix`; every `mkOutOfStoreSymlink` points here, so
  it must be a writable working tree (`home-manager/base` clones it on first switch)
- `getRelPath path` — the module's path relative to the repo root
- `getPath path` — converts a Nix store path back to its real filesystem path under `repoPath`
- `autoImport dir` — every nested `default.nix` under `dir`, except `dir`'s own
- `mkModule`, `ckModule` — module helpers (see below)
- plus every flake input, by name

`mkSystemManager` deliberately passes a **reduced** set (`device`, `system`,
`autoImport`, `mkModule`, `ckModule`) — splatting `inputs` there would shadow
system-manager's own `_module.args.system-manager` with the flake input of the
same name.

### Per-host module lists

Each `hosts/*/home.nix` carries its full `modules.home-manager.*.enable` list —
there is deliberately **no shared profile layer** (one existed briefly and was
removed; the owner prefers each host to read as a complete inventory). The
corollary: renaming or removing a module means updating every host that enables
it, and nothing but CI will tell you a host was missed. After touching any
module's directory name or any host file, run the per-host eval check (see
"Checking a host" above) — CI (`.github/workflows/eval.yml`) runs the same
checks on push.

The common toolkit currently enabled on almost every host, for orientation:
`programs.{btop,git,herdr,nvim,ssh,tmux,yazi,zsh}` + `pkgs.{dev,lang,tools}`.
When adding a module that every host should get, add it to each host file.

### mkModule pattern

Every module in `home-manager/`, `nixos/`, `nix-darwin/` and `system-manager/`
uses one of three styles. Style 3 is by far the most common (~52 modules); style 2
exists only because `mkModule` cannot declare options beyond `enable` (~4 modules,
all under `nixos/services/environments/`); style 1 is a single leftover.

```nix
# Style 1 — manual enable option
{ config, lib, ... }:
let cfg = config.modules.gnome; in
{ options.modules.gnome.enable = lib.mkEnableOption "gnome"; config = lib.mkIf cfg.enable { ... }; }

# Style 2 — path-derived option path, plus extra options
{ config, lib, getRelPath, ... }:
let relPath = getRelPath ./.; pathList = ["modules"] ++ lib.splitString "/" relPath;
    cfg = lib.getAttrFromPath pathList config;
in { options = lib.setAttrByPath pathList { enable = ...; type = ...; }; config = lib.mkIf cfg.enable { ... }; }

# Style 3 — function shorthand (use this)
{ config, mkModule, ... }:
mkModule config ./. { ... }
```

`mkModule config path content`:
1. Derives the option path from the module's filesystem path
2. Declares `enable` there
3. Wraps `content` in `lib.mkIf cfg.enable`

**The option path mirrors the directory path exactly, including intermediate
directories.** This is the single most common source of broken host files:

| Module directory | Option path |
|---|---|
| `home-manager/programs/zsh` | `modules.home-manager.programs.zsh.enable` |
| `home-manager/dotfiles/terminal/kitty` | `modules.home-manager.dotfiles.terminal.kitty.enable` — **not** `dotfiles.kitty` |
| `home-manager/dotfiles/ai/claude.d` | `modules.home-manager.dotfiles.ai."claude.d".enable` — the dot must be quoted |
| `nixos/services/kanata` | `modules.nixos.services.kanata.enable` — **not** `modules.services.kanata` |

Before writing an `enable = true` into a host, confirm the directory exists.
`find home-manager nixos nix-darwin system-manager -name default.nix` is the source of truth.

### Module tree

```
nix-darwin/          # macOS system: base, brew, launchd/kanata, setting
nixos/               # NixOS system: base, programs,
                     #   services/{environments,kanata}
system-manager/      # system-level config on non-NixOS Linux (desktop):
                     #   base, etc/trackpad, services/{docker,kanata,keyd,openssh}
                     #   Ca bon service deu DANG NGU: a14 (Ubuntu tren Snapdragon)
                     #   la host duy nhat tung bat chung, va da bi xoa 09/08/2026
                     #   khi may do chuyen han sang Windows. `desktop` van import
                     #   cay nay nhung khong bat gi.
home-manager/
  base/              # username, homeDir, stateVersion, sessionVariables
                     #   + macos/, ubuntu/, nixos/ — each carries that platform's `update` alias
  programs/          # agenix, btop, git, herdr, nvim, ssh, tmux, yazi, zsh
                     #   herdr: pkgs.herdr now builds on darwin too, so the module
                     #   owns the binary as well as the config. Cost: `herdr update`
                     #   and `herdr channel` no longer work (read-only store) --
                     #   upgrades come from a nixpkgs bump. A leftover out-of-band
                     #   ~/.local/bin/herdr shadows it, that dir precedes nix in PATH
  dotfiles/          # ai/{aichat.d,claude.d,codex.d,gemini.d,opencode.d}
                     #   claude.d: MCP user-scope lives in ~/.claude.json, which Claude
                     #   Code rewrites -- not symlinkable, and settings.json takes no
                     #   mcpServers key. So each machine needs it added out-of-band:
                     #     claude mcp add --transport http --scope user pixellab \
                     #       https://api.pixellab.ai/mcp \
                     #       --header 'Authorization: Bearer ${PIXELLAB_TOKEN}'
                     #   Single quotes, and URL before --header (it is variadic).
                     # browser/dotbrave -- CHI con brave.toml, khong con module
                     #   (go 16/08/2026); terminal/kitty
                     # macos/{hammerspoon,sleepwatcher}
                     # conda, rofi
  environments/      # fonts, gnome, i18n, i3wm, sway, hyprland, wayland
                     #   wayland: phan dung chung cua moi phien Wayland (mako,
                     #   kanshi, swaylock + goi chung). Ton tai vi sway va
                     #   hyprland cung bat tren rog se dung nhau o home.file
  pkgs/              # dev, lang, nixos, tools, ubuntu
overlays/            # local packages -- hien TRONG. Co che readDir van chay, nen
                     #   them mot thu muc goi vao day la no tu vao overlays.default
hosts/{device}/      # per-device configuration.nix and/or home.nix
configs/             # non-Nix: kanata layouts, shortcuts (apps.shared.toml)
windows/             # live parallel PowerShell config; reuses the shared dotfiles
                     #   under home-manager/dotfiles via links.ps1. Not orphaned.
```

Code đã gỡ khỏi cây nằm trong `ATTIC.md` ở gốc repo — mỗi mục kèm tag `attic/*`
và lệnh khôi phục. `git tag -l 'attic/*'` liệt kê nhanh. Trước khi kết luận "repo
này chưa bao giờ có X", tra đó đã.

Modules are auto-discovered — `home-manager/default.nix` (and the equivalent in
`nixos/`, `nix-darwin/`, `system-manager/`) is just `imports = autoImport ./.`,
which pulls in every nested `default.nix`. There is no import list to update, but
note the corollary: a module nobody enables still has its options declared on
every rebuild. That is cheap (the body sits behind `mkIf cfg.enable`), so keeping
an unused module around for reference is fine — but a **broken** one is a landmine,
since enabling it is all it takes to break eval.

### Dotfile linking pattern

Dotfiles are kept as real files in the repo and symlinked at activation time (so
edits take effect without rebuilding):

```nix
home.file."${config.xdg.configHome}/zsh/zsh.d" = {
  source = config.lib.file.mkOutOfStoreSymlink "${getPath ./.}/zsh.d";
};
```

The symlink target is a plain string, so it is **not** a reference of the
home-manager generation. It must point into the `~/.nix` working tree — never into
the store, or the dotfiles are read-only and get collected on the next GC.

### dotbrave: config trong repo, apply hoàn toàn bằng tay

**Từ 16/08/2026 Nix không còn dính gì tới dotbrave.** Cả ba module đã gỡ —
`home-manager/dotfiles/browser/dotbrave/default.nix`, `nix-darwin/dotbrave`,
`nixos/services/dotbrave` — xem `ATTIC.md`, tag
`attic/dotbrave-modules-2026-08-16`. Lý do: công cụ chưa chạy lại nhiều lần mà
không có sự cố, nên chủ máy cho nó ra khỏi đường rebuild hẳn.

Còn lại đúng hai thứ:

- **`home-manager/dotfiles/browser/dotbrave/brave.toml`** — vẫn ở nguyên chỗ,
  vẫn là nguồn chân lý cho `[shortcuts]`, `[settings]`, `[pwa]`. Chỉ là không
  còn ai đọc nó lúc rebuild.
- **`pkgs.dotbrave`** — flake input + overlay giữ nguyên, và binary được khai
  thẳng trong `home.packages` của macmini và rog. **Đừng gỡ dòng đó**: trước
  đây binary đến từ chính module (`home.packages = [cfg.package]` của module
  upstream), nên gỡ module mà không khai lại là `dotbrave` biến mất khỏi PATH
  và hết apply tay được — mất đúng thứ vừa quyết định giữ.

Áp bằng tay:

```bash
dotbrave apply --skip pwa ~/.nix/home-manager/dotfiles/browser/dotbrave/brave.toml
```

**Còn một việc dọn tay chưa xong**, ghi ở `ATTIC.md` mục "Việc phải làm tay":
nửa `[pwa]` không có teardown, nên trên macmini file
`/Library/Managed Preferences/com.brave.Browser.plist` ở lại và **vẫn bị ghim
`schg`** (nên `sudo rm` trần cũng trượt). Chừng nào chưa dọn thì `--skip pwa`
là **bắt buộc**, không phải tuỳ chọn.

**ĐÃ ĐO 16/08/2026, và giả thuyết cũ SAI.** Chỗ này từng ghi *"Trên rog thì
`[pwa]` ghi vào `/etc/brave/policies/managed/`, mà `/etc` do rebuild sở hữu
nên khả năng cao tự biến mất — chưa đo."* Đo hai đầu quanh một
`nixos-rebuild switch` thật:

```
truoc:  -rw-r--r-- root root 1943  dotbrave-pwa.json   sha256 1df7471a…
        sudo nixos-rebuild switch --impure --flake ~/.nix#rog   (RC=0)
sau:    -rw-r--r-- root root 1943  dotbrave-pwa.json   sha256 1df7471a…
```

File **sống sót nguyên vẹn**. NixOS chỉ quản những entry trong `/etc` do chính
nó tạo (`environment.etc`); file lạ thì activation không đụng. Nên áp `[pwa]`
bằng tay trên rog là bền qua rebuild, không phải vá tạm.

Cái *thực sự* biến mất thì nằm chỗ khác, và không ai lường — xem bẫy thứ ba
dưới đây.

Ba cái bẫy dưới đây là của bản thân CLI, không phải của Nix, nên vẫn còn
nguyên giá trị khi chạy tay:

- CLI bỏ qua `[shortcuts]`/`[settings]` khi **không tìm thấy DevTools endpoint
  sống** của một Brave đang chạy — không phải đơn giản là "vì Brave đang mở".
  Có endpoint thì nó áp thẳng vào trình duyệt đang chạy và không bỏ qua gì.
  Trên máy này Brave thường chạy mà không có endpoint, nên hai bảng đó thực tế
  chỉ ăn khi Brave đóng. Một lần chạy "thành công" **không** có nghĩa là chính
  sách phím tắt đã được áp — đọc output, đừng tin mã thoát.
- Chạy `dotbrave apply` trần sẽ dựng luôn kế hoạch `[pwa]`, và nó cần root nên
  sẽ hỏi sudo. **`--unattended` thì cố ý BỎ QUA `[pwa]`** — in
  `unattended: skipping [pwa] -- it needs elevated privileges` rồi **thoát 0**.
  Một lần chạy "thành công" ở chế độ đó không ghi policy nào cả. Áp `[pwa]` qua
  SSH cần TTY thật (`ssh -tt`); sudo không mật khẩu trên rog thì qua được.
- **`[pwa]` XOÁ `.desktop` và icon của PWA mà không đụng `Preferences`, và
  không nói một chữ nào.** Đây là cái tệ nhất trong ba, vì hai cái trên còn
  đọc output ra được — cái này thì output cũng im.

  Đo 16/08/2026 trên rog. `dotbrave apply --skip shortcuts --skip settings`
  in kế hoạch gồm 14 dòng `+ <url>` (toàn là *thêm*, không có dòng xoá nào),
  báo `ok -- applied and verified`, thoát 0. Kết quả thật:

  ```
  11:02:13      backup tay: 14 file .desktop
  11:07:00.304  mtime ~/.local/share/applications   <-- luc xoa
  11:07:01.868  Preferences.bak cua dotbrave        <-- dotbrave dang chay
  sau do        con 9 file; 5 cai mat sach ca icon
  ```

  Mất: YouTube, ChatGPT, Claude, Google Keep, Gmail. Chín cái sống sót vẫn giữ
  mtime cũ — không cái nào bị ghi đè, nên đây là 5 lần **xoá**, không phải
  reconcile. Brave chưa hề khởi động (`pgrep` = 0 suốt), nên không phải Brave.

  **Và Brave vẫn coi cả 14 là đã cài**: cả 14 app id còn nguyên trong
  `Preferences` trước lẫn sau (38013 B → 38003 B). Nghĩa là *"áp policy thành
  công"* và *"PWA còn hiện trong launcher"* là hai chuyện tách rời — trạng
  thái nội bộ của Brave nói một đằng, tầng tích hợp OS nói một nẻo, và không
  có tín hiệu nào ở đầu ra báo chuyện thứ hai.

  Bốn trong năm cái có phím tắt trong `configs/shortcuts/apps.shared.toml`
  (`Cap+y`, `Cap+c`, `Cap+k`, `Cap+Shift+m`), nên đây không phải chuyện thẩm mỹ.

  **Trước khi chạy `[pwa]`, sao lưu:**

  ```sh
  cp -p ~/.local/share/applications/brave-*.desktop ~/pwa-backup-$(date +%F)/
  ```

  Sửa thì mở Brave một lần: Preferences còn đủ, policy còn đủ, nên nó dựng lại
  shortcut kèm icon và tên thật — tốt hơn chép tay bản sao, vốn không có icon.

**Một hệ quả phụ, dễ chịu:** rog từng là host NixOS duy nhất mà *evaluation*
đọc file từ `repoPath` (chính là `brave.toml`), khiến
`nix eval --impure --system x86_64-linux .#nixosConfigurations.rog…` chạy từ
máy Mac báo đỏ giả `path '/…/home/<user>/.nix/…/brave.toml' does not exist`.
Gỡ module là gỡ luôn chỗ đọc đó, nên **kiểm chéo rog từ Mac lại chạy được**.

### Phím tắt focus-or-launch: beckon serve + MỘT file TOML chung

`configs/shortcuts/apps.shared.toml` — **MỘT file cho cả ba OS** (gộp
17/08/2026; trước đó là `apps.{macos,windows,linux}.toml`, và trước nữa là ba
file với `apps.linux.toml` dùng chung cho GNOME/sway/hyprland). Format phẳng:
mỗi dòng là một shortcut trọn vẹn, `"tổ_hợp_phím" = "tên app"` — không còn lớp
override/resolve nào len vào giữa như hệ cũ. `Cap` giữ = `ctrl+super+alt`
(macOS: super=Cmd; Windows/Linux: super=phím Win), do kanata sinh ra — bản thân
file này không biết `Cap` là gì.

**Một file gánh được ba OS là nhờ cú pháp chuỗi ứng viên `"A || B || C"`**: thử
trái sang phải, cái đầu tiên HÀNH ĐỘNG được thì thắng, một ứng viên trượt không
phải lỗi. Nên `"kitty || Terminal"` là kitty trên mac, Windows Terminal trên
a14, cùng một dòng.

**Sàn là beckon 0.9.7, và đây là chỗ đã cắn một lần.** Bản cũ hơn KHÔNG báo lỗi
cú pháp — nó đọc cả chuỗi thành MỘT tên app, `RegisterHotKey` vẫn thành công
nên tray icon bình thường và dòng "19 of 20 registered" vẫn đẹp, rồi chết lặng
ở bước resolve. Dấu hiệu duy nhất nằm trong `serve.log`:
`failed to launch 'kitty || Terminal': no installed app matches`. a14 đứng ở
0.9.6 và mất sáu phím tắt đúng kiểu đó (19/08/2026) — chi tiết trong header của
chính file TOML.

Tên app phải khớp **CHÍNH XÁC** chuỗi `beckon installed` in ra trên đúng máy đó:
khớp chính xác ~57 ms; trượt xuống quét toàn catalog ~463 ms trên Windows /
~79 ms macOS / ~3 ms Linux. Nhưng bậc trượt **thứ hai trở đi gần như miễn phí**,
nên chuỗi dài không tốn tiền — chỉ ứng viên ĐẦU là đáng kể. Hệ quả: **đặt tên
của Windows trước**, rồi mac, Linux cuối. Ngoại lệ duy nhất là `Cap+Space`, nơi
`"Terminal"` đặt trước sẽ làm macOS mở nhầm Terminal.app của Apple — Windows
chịu một bậc trượt ở đó, cố ý.

Engine là `beckon` ở cả năm nơi, nhưng file được ĐỌC ở hai thời điểm khác nhau
tuỳ nền tảng — đây từng là cùng hình dạng với bẫy dotbrave, nhưng dotbrave đã
ra khỏi Nix hẳn (mục trên) nên giờ **chỉ còn chỗ này** trong repo mang nó:

| Nền tảng | Đọc bằng | Sửa file rồi áp dụng bằng | Agent/task | Log |
|---|---|---|---|---|
| macOS | `beckon serve` LÚC CHẠY, tự watch file | không gì cả — watcher ăn trong ~1-2 s | launchd `com.xom11.beckon-serve` (`home-manager/programs/beckon-serve`) | `~/Library/Logs/beckon/serve.log` |
| Windows | `beckon serve` LÚC CHẠY, tự watch file | không gì cả — ăn trong ~1-2 s | task `\BeckonServe` + `\BeckonServeWatchdog` (`windows/modules/services/beckon-serve{,-watchdog}`) | `%LOCALAPPDATA%\beckon\serve.log` |
| GNOME | `builtins.fromTOML` LÚC EVAL | **`nixos-rebuild switch`** | dconf `custom-keybindings` (`home-manager/environments/gnome/launch-app.nix`) | — |
| sway | `builtins.fromTOML` LÚC EVAL | **switch** + `Tab+r` (`swaymsg reload`) | `~/.config/sway-nix/launch-app.conf` | — |
| hyprland | `builtins.fromTOML` LÚC EVAL | **switch** + `Tab+r` (`hyprctl reload`) | `~/.config/hypr-nix/launch-app.conf` | — |

mac/Windows: sửa file là đủ, watcher tự đọc lại, không switch không rebuild gì
cả — file hỏng thì beckon giữ nguyên bảng cũ và báo qua notification/toast,
sửa xong tự ăn lại. GNOME/sway/hyprland thì ngược hẳn: đây là NIX đọc file lúc
eval, không phải chương trình chạy nền đọc trực tiếp, nên sửa file mà không
switch là vô nghĩa — và sway/hyprland còn cần thêm một bước reload tay riêng
sau switch vì home-manager không tự gọi `swaymsg reload`/`hyprctl reload`.
Binding sway/hyprland chỉ là `exec beckon "<app>"` TRẦN — không
`sway-beckon.sh`, không workspace-per-app (quyết định 09/08/2026); workspace
logic là việc riêng của sway/hypr config, beckon không biết gì về workspace.
**niri cố ý CHƯA nối vào** dù cũng chạy trên rog — xem chú thích trong
`home-manager/environments/niri/default.nix`; đừng tưởng là bỏ sót. (Chú thích
đó lại trỏ tiếp sang một `README` không tồn tại — lý do thật chưa được ghi ở
đâu cả.)

**Đường dẫn config mà `beckon serve` đọc thì mỗi OS một kiểu, và đừng suy từ
máy này sang máy kia:**

- **macOS** — `~/.config/beckon/apps.toml` là `mkOutOfStoreSymlink` trỏ về
  `apps.shared.toml`, khai ở `home-manager/base/macos/default.nix`. Đây là
  đường dẫn mặc định beckon tìm, và nó **có chủ đích** — đừng xoá. (Lý do phải
  là out-of-store symlink chứ không phải `source = ../../configs/...`: beckon
  từ 0.8.0 ghi ngược vào chính file này, nên bản trong store read-only sẽ vỡ.)
- **Windows** — KHÔNG có link nào. Scheduled task truyền đường dẫn repo tường
  minh (`beckon serve <repo>\configs\shortcuts\apps.shared.toml`), và
  `serve`/`check` đều bắt buộc tham số `<CONFIG>`, không có đường lui mặc
  định. Nên một `~/.config/beckon/apps.toml` xuất hiện trên máy Windows là
  **rác** — bản mặc định beckon tự đẻ ra, không ai đọc. Đã xoá một cái như thế
  trên a14 (19/08/2026); nó chứa 3 shortcut lạ và `keyboard.caps = false`.
- **Linux** — không liên quan: nix đọc file lúc eval rồi sinh binding, không
  có tiến trình nào đọc TOML lúc chạy.

CI: job `shortcuts` trong `.github/workflows/eval.yml` chạy `beckon check`
qua glob `apps.*.toml` (nay khớp đúng một file), nhưng bằng ĐÚNG rev `beckon`
đã ghim trong `flake.lock`
(đọc qua `nix eval --raw --impure` ngay trong step) — CI kiểm cùng một binary
mà các host sẽ deploy, không phải bản mới nhất thượng nguồn của beckon.

**Từ beckon 0.8.0, luồng này chạy CẢ HAI CHIỀU.** Bản đó mọc thêm cửa sổ
Settings, và `crates/beckon-core/src/config_write.rs` **ghi ngược** lựa chọn vào
chính file `apps.shared.toml` — đo trên a14 12/08/2026, hai dòng
`keyboard.caps` và `keyboard.caps_tap` tự xuất hiện trong file đó mà không ai
sửa. Nghĩa là file này giờ cùng hạng với `pi.d/settings.json` và
`nvim-pack-lock.json`: **một chương trình đang chạy có thể làm bẩn working tree
bất cứ lúc nào.** Hệ quả cụ thể: `git pull --ff-only` trên a14 sẽ bị chặn, và
`git status` bẩn không có nghĩa là ai đó quên commit. Trước khi kết luận "có
người sửa tay", hỏi xem cửa sổ Settings của beckon có được mở không.

Ba bẫy kế thừa từ đợt dọn 09/08/2026, đáng nhớ vì không có gì tự báo khi vi
phạm:

- `,` `.` `/` đã thuộc về `window-manager.ahk` (snap trái/phải/max, CÙNG tổ
  hợp `Cap`) — đừng thêm ba phím này vào `apps.shared.toml`.
- Log "N shortcuts registered" từ beckon v0.4.1 đếm số đăng ký THÀNH CÔNG
  ("X of N ... (M failed)" khi có phím trượt, kèm đúng một toast tổng hợp).
  Trên binary cũ hơn (< 0.4.1) con số đó là số dòng parse — đừng tin một mình
  nó, phải đọc kèm dòng lỗi phía trên.
- Xác nhận AHK/Hammerspoon đã reload thật bằng CreationDate của tiến trình
  (process mới có mốc khởi động mới), đừng tin cảm giác "vừa bấm phím
  reload" — bài học 09/08/2026.

Máy móc cũ của hệ `apps.toml` dùng chung — `parse.lua`, `parse.ahk`,
`dump.nix`, `sync.sh`, `check-consumers.sh`, `apps.expected.tsv` (golden
file), `LaunchApp.spoon`, `launch-app.ahk`,
`windows/tests/shortcutsParse.Tests.ps1` — đã XOÁ HOÀN TOÀN ngày 09/08/2026
(`shortcuts: xoa apps.toml cu + hai parser tay + golden + spoon/ahk
launch-app`). Plan và spec của đợt migration nằm trong
`docs/superpowers/plans/` và `docs/superpowers/specs/` (cả hai đã gitignore,
không lên web public).

### Secrets (agenix)

Secrets get the same "edit without rebuilding" property, but by a different
route — `.age` is ciphertext, so a symlink alone is no good and a decrypt step
has to run. Two rules make that work:

```nix
file = "${pwd}/age.d/apikey.zsh.age";   # string, NOT ./age.d/apikey.zsh.age
```

A path literal copies the ciphertext into the store and freezes it there until
the next switch. `types.path` accepts an absolute-path string and leaves it
alone, so the decrypt reads the working tree. Every `age.secrets.<n>.file` in
this repo must be written that way.

`agenix-reload <file.age>` then re-decrypts into wherever that secret installs.
The nvim `age-edit` plugin calls it on `:w`, so editing a secret there applies
immediately; after `agenix -e` or a `git pull`, run it by hand. The mapping is
generated from `age.secrets`, so **adding** a secret still needs a switch —
only changing one's contents does not.

Note `age.secrets` is consumed by a launchd agent (systemd unit on linux), not
by `home.activation` — so a decrypt that fails never fails the switch, it just
lands in `~/Library/Logs/agenix/stderr`.

`home-manager/programs/agenix` pins that agent's `KeepAlive` to
`{ SuccessfulExit = false; }` and its `ThrottleInterval` to 60. agenix ships
`Crashed = false` alongside `SuccessfulExit`, which relaunches the job every
~10s forever; dropping the whole key instead would also lose the retry that
lets a fresh machine heal itself once the real `~/.ssh/id_ed25519` is dropped
in (its own generated key decrypts nothing). That retry is blind, so a host
with no usable key logs 425 bytes a minute until one appears — the throttle is
what keeps that at ~600 KB/day rather than ~3.7 MB.

### Adding a new module

1. Create `home-manager/<category>/<name>/default.nix` using `mkModule config ./. { ... }`
2. Enable it per-device in `hosts/{device}/home.nix` under
   `modules.home-manager.<category>.<name>.enable = true` (in every host file,
   if every host should get it)
3. Confirm the hosts you touched still evaluate (see "Checking a host" above)

## Git

- Do NOT add `Co-Authored-By` lines to commit messages.
