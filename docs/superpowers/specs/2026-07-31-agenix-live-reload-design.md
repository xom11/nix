# Sửa secret agenix là apply luôn, không cần rebuild

Ngày: 2026-07-31

## Vấn đề

Mọi dotfile trong repo này dùng `mkOutOfStoreSymlink`, nên sửa file trong
`~/.nix` là có hiệu lực ngay. Hai file secret thì không:

- `home-manager/programs/zsh/age.d/apikey.zsh.age`
- `home-manager/programs/ssh/age.d/config.age`

Sửa chúng xong phải `darwin-rebuild switch` mới thấy giá trị mới.

## Nguyên nhân — hai lớp đóng băng chồng lên nhau

**Lớp 1 — ciphertext bị photocopy vào store.** `zsh/default.nix:20` và
`ssh/default.nix:37` khai báo:

```nix
file = ./age.d/apikey.zsh.age;   # path literal
```

Path literal của Nix nghĩa là "copy vào store". Script giải mã mà agenix sinh
ra nhúng cứng đường dẫn store:

```
age --decrypt -i ~/.ssh/id_ed25519 -o "$TMP_FILE" \
  "/nix/store/1yjcww7sal7dardj1yi50rr6sznqw2a3-apikey.zsh.age"
```

Sửa file trong repo không đụng gì tới bản copy đó. Chỉ rebuild mới sinh store
path mới.

**Lớp 2 — bước giải mã chỉ chạy khi được nạp lại.** Module home-manager của
agenix **không** dùng `home.activation`. Nó đăng ký một launchd agent trên
darwin và một systemd user service trên linux (`modules/age-home.nix:221-245`):

```
$ launchctl list | grep agenix
-  0  org.nix-community.home.activate-agenix
```

`RunAtLoad = true`, nên nó chạy mỗi lần rebuild nạp lại agent — và không lúc
nào khác. Nó không biết file trong repo vừa đổi.

**Vì sao không thể chỉ symlink như các dotfile khác.** `.age` là chữ mã hoá;
zsh và ssh không đọc được. Bắt buộc phải có bước giải mã, mà giải mã thì sinh
ra file mới. Mục tiêu do đó không phải "biến secret thành symlink" mà là "giữ
bước giải mã, nhưng làm nó chạy lại được mà không cần rebuild".

## Hai sự thật đã kiểm chứng

**`types.path` nhận chuỗi tuyệt đối mà không copy vào store.** Kiểm bằng eval:

```
$ nix eval --impure --expr 'let lib = (import <nixpkgs> {}).lib;
    r = lib.evalModules { modules = [ {
      options.f = lib.mkOption { type = lib.types.path; };
      config.f = "/Users/lenamkhanh/.nix/.../apikey.zsh.age"; } ]; };
  in r.config.f'
"/Users/lenamkhanh/.nix/.../apikey.zsh.age"
```

Chuỗi ra nguyên chuỗi, không thành store path.

**Đích của secret hiện là symlink xuyên qua lớp generation của agenix:**

```
~/.config/zsh/apikey.zsh
  → /var/folders/nj/.../T/agenix/zsh-apikey
  → /private/var/folders/nj/.../T/agenix.d/34192/zsh-apikey
```

Ghi đè vào điểm cuối là có hiệu lực ngay, không đụng tới home-manager
generation.

## Thiết kế

Ba chỗ thay đổi.

### 1. `home-manager/programs/agenix/default.nix` — thêm `agenix-reload`

Một `pkgs.writeShellApplication` sinh từ `config.age.secrets`, nằm cùng chỗ với
`recipients`/`identity` mà module đã xuất cho plugin nvim (dòng 30-31).

Bảng ánh xạ *ciphertext → đích → mode* được nướng thẳng vào script lúc build,
một nhánh `case` cho mỗi secret. Không có file manifest phải giữ đồng bộ, không
cần `jq`. Bảng chỉ đổi khi **thêm/bớt** secret — việc đó vốn đã là thay đổi Nix
và vẫn cần rebuild.

Cách dùng:

```
agenix-reload <đường-dẫn-.age>   # giải mã lại đúng một secret
agenix-reload                     # giải mã lại tất cả
```

Lõi của `reload_one`:

```
dest=$(readlink -f "$target") hoặc "$target" nếu không resolve được
tmp=$(mktemp "$dest.XXXXXX")
age -d -i "$identity" "$src" > "$tmp"
chmod "$mode" "$tmp"
mv -f "$tmp" "$dest"
```

`readlink -f` để xuyên qua lớp symlink generation của agenix, nhờ đó giữ nguyên
mô hình generation và **không** phải đổi `symlink = false`.

Nếu `readlink -f` trượt — trường hợp macOS đã dọn `/var/folders/…/T` làm symlink
treo — script rơi về chính đường dẫn đích và ghi file thật lên đó. Đây là điểm
được thêm: hiện tại gặp cảnh này phải rebuild mới có lại file.

### 2. `zsh/default.nix` và `ssh/default.nix` — gỡ lớp đóng băng 1

```nix
file = "${pwd}/age.d/apikey.zsh.age";   # chuỗi, không phải path literal
```

`pwd = getPath ./.` đã có sẵn trong cả hai file, đang dùng cho
`mkOutOfStoreSymlink`. Secret từ nay đi theo đúng pattern đó.

### 3. Sửa kèm — launchd agent của agenix đang chạy lặp vô tận

Phát hiện lúc kiểm chứng, không nằm trong yêu cầu ban đầu nhưng **làm hỏng
chính tính năng này**, nên sửa luôn.

agenix khai báo (`modules/age-home.nix:238-241`):

```nix
KeepAlive = { Crashed = false; SuccessfulExit = false; };
```

Với launchd, `Crashed = false` nghĩa là *"khởi động lại khi tiến trình thoát mà
không crash"* — mà script này luôn thoát 0. Hệ quả: agent chạy lại mỗi ~10 giây,
mãi mãi. Đo được trên macmini ngày 31/07/2026:

```
generation lúc T+0 : 34257
generation lúc T+25: 34259     → 2 lần trong 25 giây
log ~/Library/Logs/agenix/stdout: 4.7 MB
```

Với tính năng này thì đó là lỗi chí mạng: mọi kết quả của `agenix-reload` bị
agent ghi đè trong vòng mươi giây.

Sửa trong module của repo, không đụng upstream:

```nix
launchd.agents.activate-agenix.config.KeepAlive = lib.mkForce false;
```

`RunAtLoad = true` vẫn giữ, nên agent vẫn giải mã một lần mỗi switch — đúng
những gì nó cần làm. Systemd unit trên linux là `Type = oneshot` nên không dính.

### 4. `nvim/lua/extras/age-edit.lua` — nối vào `BufWriteCmd`

Sau khi mã hoá thành công (sau dòng 87), gọi `agenix-reload` với chính file vừa
ghi. Đồng bộ, nên bắt được exit code và stderr để `vim.notify`.

Bỏ qua im lặng nếu `agenix-reload` không có trong PATH, để host không bật agenix
vẫn dùng plugin bình thường.

## Luồng dữ liệu

```
nvim :w trên apikey.zsh.age
 ├─ BufWriteCmd: age -R recipients -o ~/.nix/…/apikey.zsh.age    (đã có)
 └─ agenix-reload ~/.nix/…/apikey.zsh.age                        (mới)
      ├─ khớp đường dẫn với bảng case → biết đích + mode
      ├─ age -d -i <identity> <ciphertext live> > $tmp
      ├─ chmod 0400 $tmp
      └─ mv -f $tmp $(readlink -f ~/.config/zsh/apikey.zsh)
```

Không `nix eval`, không build.

## Xử lý lỗi

| Tình huống | Hành vi |
|---|---|
| `age -d` trượt (sai key, ciphertext hỏng) | ghi ra `$tmp` trước nên plaintext cũ còn nguyên; script exit khác 0; nvim `vim.notify` mức WARN kèm stderr của `age` |
| file `.age` không nằm trong `age.secrets` | exit 0, ghi một dòng ra stderr. `secrets.nix` tự quét mọi `.age` nhưng chỉ 2 file được nối vào `age.secrets` |
| không đọc được `~/.config/agenix/identity` | exit 1 kèm thông báo rõ |
| `agenix-reload` không có trong PATH | hook nvim bỏ qua, không kêu |

Mức WARN chứ không phải ERROR là có chủ ý: mã hoá đã thành công nên repo vẫn
đúng, chỉ có bản rõ ở đích là cũ.

## Kiểm chứng

1. `nix eval --impure .#darwinConfigurations.macmini.system.drvPath` vẫn eval được.
2. Sau một lần rebuild, script của launchd agent phải nhắc
   `/Users/lenamkhanh/.nix/…age`, không còn `/nix/store/…age`.
3. Đầu-cuối: sửa `apikey.zsh.age` trong nvim, `:w`, so `sha256` của
   `~/.config/zsh/apikey.zsh` trước và sau.
4. Kiểm âm: trỏ identity sang key sai rồi `:w` — nvim phải báo lỗi **và**
   plaintext cũ vẫn còn nguyên.

## Giới hạn đã biết

- **Shell đang mở không tự có giá trị mới.** `~/.ssh/age.d/config` thì ăn ngay
  vì ssh đọc lại file mỗi lần connect. Còn `apikey.zsh` chỉ vào shell mới —
  không tiến trình ngoài nào tiêm biến vào zsh đang chạy được.
- **Rollback generation không còn kéo theo secret**, vì ciphertext đã ra khỏi
  store. Nơi rollback secret từ nay là git. Đây đúng là đánh đổi vốn đã chấp
  nhận cho mọi dotfile `mkOutOfStoreSymlink` khác.
- **Thêm secret mới vẫn cần rebuild**, vì `age.secrets.<tên>` là khai báo Nix.
  Chỉ sửa nội dung là hết cần.
- `hosts/a14/home.nix:46` cũng bật agenix. Script viết portable cho cả linux
  nhưng không kiểm chứng được ở đó — theo ghi chú thì a14 giờ chỉ còn Windows.
- Chỉ đường sửa qua nvim là tự động. Sửa bằng `agenix` CLI hay sau `git pull`
  thì gõ `agenix-reload` bằng tay.

## Phạm vi không làm

- Không đổi `symlink = false` — giữ nguyên mô hình generation của agenix.
- Không dựng watcher (launchd `WatchPaths` / systemd path unit). Thêm một daemon
  phải nuôi, trong khi đường sửa thật sự đã được hook nvim phủ.
- Không đụng tới `secrets.nix`, `keys.nix`, hay quy trình mã hoá.
