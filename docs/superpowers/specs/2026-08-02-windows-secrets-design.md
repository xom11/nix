# Secret trên Windows: dùng chung `.age` với macOS/Linux

Ngày: 2026-08-02

## Vấn đề

Trên macOS và Linux, 14 biến môi trường (API key, token) đến từ một file duy
nhất trong repo:

```
home-manager/programs/zsh/age.d/apikey.zsh.age
```

agenix giải mã nó ra `~/.config/zsh/apikey.zsh`, và `.zshrc` `source` file đó.
Sửa nội dung thì `agenix-reload` áp dụng ngay, không cần rebuild.

Máy Windows (`a14`) không có gì tương đương. Không có agenix, không có zsh, và
`export K=V` không phải cú pháp PowerShell hiểu được.

## Điều kiện đã có sẵn — không phải dựng lại từ đầu

**File `.age` đã mã hoá cho máy Windows từ đầu.** `home-manager/programs/ssh/authorized_keys`
có 4 recipient: `nixos`, `macmini`, `windows`, `kln@a14`. Hai cái sau là khoá
của máy Windows. Nghĩa là **không phải mã hoá lại gì cả** — ciphertext hiện tại
giải mã được trên `a14` ngay hôm nay.

**Hạ tầng Windows đã đủ.** `windows/apply.ps1` có danh sách `$modules`, nạp
`modules/<tên-có-chấm>/module.ps1`. `lib/` đã có `Symlink.psm1`, `Package.psm1`,
`ScheduledTask.psm1`, `Logging.psm1`. Profile pwsh đã có thư mục drop-in
`ps1.d/`. Module `packages.scoop` đã cài sẵn 20+ CLI, thêm `age` là một dòng.

## Ba quyết định, và vì sao

### 1. Phạm vi: chỉ shell pwsh

Không ghi vào User-scope environment variable (registry). Windows *cho phép*
làm thế để app mở từ GUI cũng thấy — nhưng đó là mở rộng phạm vi so với Unix,
nơi `export` trong zsh không bao giờ tới được app GUI. Giữ hai nền tảng cùng
một ngữ nghĩa.

### 2. Giữ nguyên định dạng `export K="V"`

Đã cân nhắc đổi sang dotenv trung lập (`K="V"`, zsh nạp bằng `set -a`). Bỏ, vì:

- Phía Windows **không đỡ hơn**: parser chỉ khác đúng một cụm ngoặc tuỳ chọn,
  `^(?:export\s+)?(\w+)=(.*)$` so với `^(\w+)=(.*)$`.
- Phải mã hoá lại, và **mọi host Unix phải switch một lần**; trong lúc chuyển
  tiếp máy chưa switch mất sạch biến môi trường.
- Sinh ra một bẫy mới: `source file` mà quên `set -a` thì biến được đặt nhưng
  **không export**. `echo $VAR` vẫn in ra bình thường, chỉ tiến trình con không
  thấy. Hỏng âm thầm với triệu chứng đánh lừa.

Chữ `export` là nhãn an toàn gắn liền vào từng dòng. Bỏ nó đi là chuyển trách
nhiệm sang người đọc file.

**Ràng buộc đi kèm:** value chỉ được là chữ thuần — không `$`, không backtick,
không `$(...)`, và không nháy `'` hay `"` bên trong. zsh nội suy, và còn ghép
các từ nháy liền nhau; parser PowerShell lấy nguyên chuỗi và chỉ bóc đúng cặp
nháy bọc ngoài. Lệch âm thầm cả hai chiều.

Đã kiểm cả 14 value hiện tại: không value nào chứa bất kỳ ký tự nào trong nhóm
đó, nên luật ghi vào `CLAUDE.md` là để giữ nguyên trạng chứ không phải sửa gì.
(Không liệt kê tập ký tự thực tế ở đây — repo này public, và đó vẫn là metadata
về nội dung secret thật.)

### 3. Giải mã sẵn lúc `apply.ps1`, không giải mã mỗi lần mở shell

Phương án "giải mã trong RAM mỗi lần mở shell" không để lại plaintext trên đĩa,
nhưng tốn một lần spawn `age.exe` cho mỗi shell — trên ARM64 chạy qua giả lập
x64 còn tệ hơn.

Điều đó mâu thuẫn trực tiếp với chính sách hiệu năng đã thiết lập trong
`Microsoft.PowerShell_profile.ps1`: file đó thay pipeline `Where-Object` bằng
`foreach` để tiết kiệm 43 ms, và cache `oh-my-posh init` để giảm 227 ms xuống
94 ms. Đốt 30–60 ms mỗi shell cho age là đi ngược lại.

Rủi ro plaintext-at-rest của phương án này **bằng đúng** rủi ro đã chấp nhận ở
`~/.config/zsh/apikey.zsh` trên mac. Không có lý do gì Windows phải khắt khe hơn.

## Thiết kế

### 1. `windows/lib/Secrets.psm1` — mới

`apply.ps1` không có tham số chạy lẻ một module, nên logic giải mã phải nằm ở
`lib/` để cả module lẫn hàm reload trong shell cùng gọi được.

```powershell
function ConvertFrom-ShellEnv {
    param([Parameter(Mandatory)][string]$Text)
    # Trả về [ordered]@{ NAME = 'value' }. Bỏ qua dòng trống, dòng bắt đầu bằng #,
    # và mọi dòng không khớp -- file nguồn hiện có 1 dòng không phải export.
}

function Update-PwshSecrets {
    param([string]$RepoRoot, [switch]$Quiet)
    # 1. $key = "$env:USERPROFILE\.ssh\id_ed25519"
    #    $age = "$RepoRoot\home-manager\programs\zsh\age.d\apikey.zsh.age"
    # 2. age -d -i $key $age  -> text trong RAM, không bao giờ chạm đĩa
    # 3. ConvertFrom-ShellEnv
    # 4. Ghi ra file .ps1 qua temp + move
    # 5. Trả về số biến đã ghi
}
```

Quy tắc parse:

| Đầu vào | Xử lý |
|---|---|
| `export NAME="value"` | lấy `NAME`, `value` |
| `NAME="value"` | như trên (`export` là tuỳ chọn) |
| `NAME='value'` | bỏ nháy đơn bọc ngoài |
| dòng trống, `# ...` | bỏ qua |
| bất kỳ dòng nào khác | **bỏ qua, không lỗi** |

Sinh ra `$env:NAME = 'value'`, escape `'` thành `''`. Nháy đơn PowerShell không
nội suy, nên `$` và backtick trong value vô hại kể cả nếu luật ở mục 2 bị vi phạm.

### 2. Ghi file bằng temp rồi move

Giống hệt cách `agenix-reload` làm trên Unix, và vì cùng một lý do: giải mã hỏng
**không được** phá bản plaintext cũ.

```
%LOCALAPPDATA%\pwsh-secrets\.tmp.<random>   -> ghi + set ACL
                            \apikey.ps1     <- Move-Item -Force
```

ACL đặt trên file temp trước khi move, để không có khoảnh khắc nào file đích tồn
tại với quyền kế thừa mặc định:

```powershell
icacls $tmp /inheritance:r /grant:r "${env:USERNAME}:(R,W)"
```

`(R,W)` chứ không phải `(R)`: lần chạy sau còn phải ghi đè. Chủ sở hữu vẫn đổi
được ACL nên `(R)` cũng chạy, nhưng `(R,W)` mô tả đúng ý định hơn.

Thư mục `%LOCALAPPDATA%\pwsh-secrets\` đặt cạnh `pwsh-init-cache` đã có sẵn —
cùng quy ước đặt tên, và **nằm ngoài `~/.nix`**, đúng nguyên tắc "không bao giờ
ghi plaintext vào cây repo" trong `CLAUDE.md`.

### 3. `windows/modules/programs/agenix/module.ps1` — mới

Vỏ mỏng gọi `Update-PwshSecrets`, theo đúng khuôn `@{ Description; Apply }` của
các module khác.

Thứ tự kiểm tra, và **mọi trường hợp thiếu đều `return` chứ không `throw`**:

| Tình huống | Hành vi |
|---|---|
| không có `age` trong PATH | `Write-Warn`, return |
| không có `~/.ssh/id_ed25519` | `Write-Skip`, return |
| không có file `.age` | `Write-Warn`, return |
| `age -d` trả mã lỗi | `Write-Fail`, return |
| thành công | `Write-OK "<n> secrets"` |

Đây là cùng nguyên tắc với bản vá `agenix-reload` ngày 31/07 (một secret hỏng
không chặn phần còn lại) và là bài học từ vụ `linkGeneration` chết kéo sập cả
activation trên airm3 ngày 02/08: một thành phần phụ không được làm hỏng cả run.

### 4. `home-manager/dotfiles/windows/pwsh/ps1.d/apikey.ps1` — mới

```powershell
$SecretsFile = Join-Path $env:LOCALAPPDATA 'pwsh-secrets\apikey.ps1'
if (Test-Path -LiteralPath $SecretsFile) { . $SecretsFile }
```

File này **nằm trong repo và không bao giờ chứa giá trị** — nó chỉ nạp file sinh
ra ở `%LOCALAPPDATA%`.

`links.ps1` không phải sửa: mục `dotfiles.pwsh` link nguyên cả thư mục `ps1.d`.

**Nhưng profile phải sửa.** Nó *không* glob thư mục — dòng 62 liệt kê tay:

```powershell
foreach ($file in 'env.ps1', 'alias.ps1', 'functions.ps1') {
```

Thêm `'apikey.ps1'` vào danh sách đó. Thứ tự không quan trọng (toàn phép gán).

Vị trí này là cố ý: khối đó có comment *"always on: plain definitions, cheap
enough to matter to scripts too"* — nó chạy **cả khi không interactive**. Nghĩa
là `pwsh -c` qua SSH cũng có token, đúng điều cần cho script chạy từ xa.

Chi phí: một `Test-Path` + dot-source ~14 phép gán. Dưới 1 ms.

### 5. `ps1.d/functions.ps1` — thêm hàm reload

```powershell
function Update-Secrets {
    Import-Module "$env:USERPROFILE\.nix\windows\lib\Secrets.psm1" -Force
    Update-PwshSecrets -RepoRoot "$env:USERPROFILE\.nix"
    . (Join-Path $env:LOCALAPPDATA 'pwsh-secrets\apikey.ps1')
}
Set-Alias agenix-reload Update-Secrets
```

`Import-Module` nằm **trong thân hàm**, chỉ chạy khi gọi — không tốn gì lúc mở
shell.

Điểm này Windows hơn Unix: `$env:` ánh xạ thẳng vào environment block của tiến
trình, nên `agenix-reload` **làm mới được chính shell đang chạy**. Trên Unix,
`agenix-reload` chỉ ghi lại file, shell đang mở phải `source` lại.

### 6. Ba sửa đổi một dòng

- `windows/modules/packages/scoop/module.ps1`: thêm `'age'` vào `-Packages`.
- `windows/apply.ps1`: thêm `'programs.agenix'` vào `$modules`, đặt **sau**
  `packages.scoop` (cần `age`) và **sau** `dotfiles.pwsh` (cần `ps1.d` đã link).
- `Microsoft.PowerShell_profile.ps1` dòng 62: thêm `'apikey.ps1'` vào danh sách
  nạp. Xem mục 4 — không thêm dòng này thì file drop-in không bao giờ chạy.

### 7. `windows/tests/agenix.Tests.ps1` — mới

Pester, theo khuôn 13 test module hiện có: assert tĩnh trên nội dung module +
test hành vi của parser.

**Toàn bộ dữ liệu test là bịa.** Không một giá trị thật nào xuất hiện trong
file test — repo này public, và test là thứ dễ quên nhất khi rà secret.

Ca kiểm:

- `export K="v"`, `K="v"`, `K='v'` đều ra cùng kết quả
- dòng trống / `# comment` / dòng rác bị bỏ qua, không ném lỗi
- value chứa `'` được escape thành `''`
- value chứa `$` và backtick không bị nội suy (nhờ nháy đơn)
- đầu vào rỗng → 0 biến, không lỗi
- thiếu khoá → `Write-Skip`, không `throw`
- `age` trả mã khác 0 → file cũ **không** bị đụng tới

## Luồng dữ liệu

```
home-manager/programs/zsh/age.d/apikey.zsh.age      MỘT file, trong repo
   │  (mã hoá cho 4 recipient: nixos, macmini, windows, kln@a14)
   │
   ├─ macOS/Linux ── agenix (launchd/systemd) ──→ ~/.config/zsh/apikey.zsh
   │                 agenix-reload                 .zshrc: source
   │
   └─ Windows ────── apply.ps1 → programs.agenix ─→ %LOCALAPPDATA%\pwsh-secrets\apikey.ps1
                     Update-Secrets                 ps1.d/apikey.ps1: dot-source
```

Sửa trên mac bằng nvim (`:w` gọi `agenix-reload`) → commit → `git pull` trên a14
→ `Update-Secrets`. Không có file secret thứ hai phải giữ đồng bộ.

## Ranh giới "cần chạy lại apply" — giống Unix

| Việc | Unix | Windows |
|---|---|---|
| Sửa **nội dung** secret | `agenix-reload` | `Update-Secrets` |
| **Thêm** secret mới | switch | `apply.ps1` |

Khác một điểm: Windows **không tự làm mới sau `git pull`** — không có launchd
tương đương. Phải gọi tay. Điều này giống Linux hơn là macOS (systemd unit của
agenix là `oneshot`, không có `Restart=`, cũng không tự lành).

## Xử lý lỗi

Nguyên tắc chung: **thiếu thì bỏ qua, hỏng thì báo, không bao giờ để file cũ
tệ hơn trước.**

- Máy chưa có khoá → không có secret, không có lỗi, `apply.ps1` chạy tiếp. Đúng
  hành vi đã kiểm chứng trên Unix ngày 31/07.
- Giải mã hỏng → file `apikey.ps1` cũ giữ nguyên (nhờ temp + move). Shell mở sau
  đó vẫn có bộ giá trị cũ thay vì mất trắng.
- `ps1.d/apikey.ps1` không thấy file đích → im lặng bỏ qua. Máy chưa chạy
  `apply.ps1` lần nào vẫn mở được shell bình thường.

## Kiểm chứng

Chạy được ngay trên mac (không cần máy Windows):

- `Invoke-Pester windows/tests/agenix.Tests.ps1` — pwsh có trên mac qua nix.
- Đối chiếu số biến parser đọc được với `grep -c '^export ' ~/.config/zsh/apikey.zsh`.

Cần máy `a14`:

- `apply.ps1` chạy hết, module báo `OK 14 secrets`.
- Mở shell mới → `$env:PIXELLAB_TOKEN` có giá trị.
- Đo thời gian mở shell trước/sau, xác nhận chênh lệch dưới 5 ms.
- ACL: `icacls %LOCALAPPDATA%\pwsh-secrets\apikey.ps1` chỉ liệt kê chính user.
- Sửa secret trên mac → pull → `Update-Secrets` → giá trị mới có ngay trong
  shell đang mở.

## Chưa xác minh được — máy `a14` hiện không kết nối

Hai điều phải kiểm trước khi triển khai, không phải giả định:

1. **`age` bản Windows ARM64.** Upstream chỉ phát hành `windows-amd64`; ARM64
   chạy qua giả lập x64. Cần xác nhận scoop cài được và chạy được. Nếu không,
   repo đã có bucket riêng `xom11/scoop-bucket` để tự đóng gói.
2. **`~/.ssh/id_ed25519` trên a14** tồn tại và **không đặt passphrase** — có
   passphrase thì `apply.ps1` sẽ treo chờ nhập giữa chừng.

## Phạm vi không làm

- **Không** ghi vào User-scope environment variable (registry). App mở từ GUI
  sẽ không thấy các biến này — đúng như trên Unix.
- **Không** cấp secret cho scheduled task chạy dưới SYSTEM hoặc session 0.
- **Không** đưa `config.age` (ssh config) sang Windows. OpenSSH trên Windows có
  hỗ trợ `Include` nên làm được, nhưng đó là việc khác.
- **Không** thêm scheduled task tự chạy `Update-Secrets` lúc logon. Gọi tay sau
  `git pull`, giống Linux.
- **Không** đổi định dạng file nguồn. Xem quyết định 2.
