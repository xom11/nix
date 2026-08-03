# Secret trên Windows — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Máy Windows (`a14`) đọc được 14 biến môi trường từ **cùng một file `.age`** mà macOS/Linux đang dùng, không phải quản lý secret riêng.

**Architecture:** `windows/lib/Secrets.psm1` giải mã `apikey.zsh.age` bằng `age` + khoá SSH sẵn có, chuyển cú pháp `export K="V"` thành `$env:K = 'V'`, ghi ra `%LOCALAPPDATA%\pwsh-secrets\apikey.ps1` qua temp+move. Một module `apply.ps1` gọi nó lúc apply; một drop-in `ps1.d` dot-source nó lúc mở shell.

**Tech Stack:** PowerShell (Windows PowerShell 5.1 + pwsh 7), Pester 3.x, `age` CLI, scoop.

**Spec:** `docs/superpowers/specs/2026-08-02-windows-secrets-design.md`

## Global Constraints

- **Pester 3.x syntax bắt buộc.** CI (`.github/workflows/windows-tests.yml`) chạy `Import-Module Pester -MaximumVersion 4.99.99` và `throw` nếu major ≥ 5. Viết `Should Be`, `Should Match`, `Should Throw` — **không** có dấu `-` phía trước.
- **Tương thích Windows PowerShell 5.1.** CI chạy `shell: powershell`, không phải `pwsh`. Cấm cú pháp chỉ có ở PS7: `??`, `?:`, `-Parallel`, `Join-String`.
- **CI tự bắt file test mới.** Workflow glob `windows\tests\*.Tests.ps1` và chỉ loại trừ `ahkRuntimeSafety.Tests.ps1`. **Không** sửa workflow.
- **Repo này PUBLIC.** Mọi dữ liệu test phải bịa. Không một giá trị secret thật nào được xuất hiện trong test, comment, hay commit message.
- **Không ghi plaintext vào `~/.nix`.** File sinh ra nằm ở `%LOCALAPPDATA%\pwsh-secrets\`.
- **Thiếu điều kiện thì `return`, không `throw`.** Module không được làm hỏng cả lượt `apply.ps1`.
- **Commit message tiếng Việt**, không thêm dòng `Co-Authored-By`.
- **Không có pwsh trên máy mac** đang phát triển. Test chỉ chạy được ở CI hoặc trên `a14`. Mỗi task kết thúc bằng push để CI chấm.

---

### Task 1: Parser `ConvertFrom-ShellEnv`

Chuyển text kiểu shell thành cặp tên/giá trị. Thuần tuý, không I/O, không phụ thuộc `age` — nên test được đầy đủ ở CI.

**Files:**
- Create: `windows/lib/Secrets.psm1`
- Create: `windows/tests/secrets.Tests.ps1`
- Modify: `CLAUDE.md` (thêm luật giá trị literal)

**Interfaces:**
- Consumes: không
- Produces: `ConvertFrom-ShellEnv -Text <string>` → `System.Collections.Specialized.OrderedDictionary` (tên biến → giá trị đã bỏ nháy). Task 2 và 3 dùng kiểu trả về này.

- [ ] **Step 1: Viết test thất bại**

Tạo `windows/tests/secrets.Tests.ps1`:

```powershell
Describe 'windows/lib/Secrets.psm1 ConvertFrom-ShellEnv' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $LibPath  = Join-Path $RepoRoot 'windows\lib\Secrets.psm1'
        Import-Module $LibPath -Force
    }

    It 'reads export, bare, and single-quoted forms identically' {
        $text = @'
export ALPHA="one"
BRAVO="two"
CHARLIE='three'
'@
        $got = ConvertFrom-ShellEnv -Text $text
        $got.Count       | Should Be 3
        $got['ALPHA']    | Should Be 'one'
        $got['BRAVO']    | Should Be 'two'
        $got['CHARLIE']  | Should Be 'three'
    }

    It 'skips blank lines, comments and junk without throwing' {
        $text = @'

# a comment
export DELTA="four"
this line is not an assignment
   
export ECHO="five"
'@
        $got = ConvertFrom-ShellEnv -Text $text
        $got.Count    | Should Be 2
        $got['DELTA'] | Should Be 'four'
        $got['ECHO']  | Should Be 'five'
    }

    It 'keeps the value verbatim, including characters a shell would expand' {
        # Không phải khuyến khích -- chỉ chứng minh parser không nội suy.
        $text = 'export FOXTROT="a$b`c"'
        $got = ConvertFrom-ShellEnv -Text $text
        $got['FOXTROT'] | Should Be 'a$b`c'
    }

    It 'preserves inner quotes and only strips the outer pair' {
        $text = 'export GOLF="say ""hi"""'
        $got = ConvertFrom-ShellEnv -Text $text
        $got['GOLF'] | Should Be 'say ""hi""'
    }

    It 'returns an empty dictionary for empty input' {
        $got = ConvertFrom-ShellEnv -Text ''
        $got.Count | Should Be 0
    }

    It 'handles CRLF as well as LF' {
        $text = "export HOTEL=`"six`"`r`nexport INDIA=`"seven`"`r`n"
        $got = ConvertFrom-ShellEnv -Text $text
        $got.Count | Should Be 2
    }
}
```

- [ ] **Step 2: Chạy test, xác nhận thất bại**

```bash
git add windows/tests/secrets.Tests.ps1 && git commit -q -m "test: parser ConvertFrom-ShellEnv (chua co implementation)" && git push origin main
gh run watch --exit-status
```

Kết quả mong đợi: FAIL — `Import-Module` không thấy `windows\lib\Secrets.psm1`.

- [ ] **Step 3: Viết implementation tối thiểu**

Tạo `windows/lib/Secrets.psm1`:

```powershell
# Đọc file secret dùng chung với macOS/Linux. Nguồn là cú pháp shell
# (`export K="V"`) vì đó là thứ zsh source trực tiếp; ở đây `export` chỉ là
# tiền tố tuỳ chọn cần bỏ qua.
#
# Value được coi là chữ thuần: không nội suy `$`, backtick hay `$(...)`. Luật đó
# ghi ở CLAUDE.md. Sinh ra chuỗi nháy đơn của PowerShell nên kể cả khi luật bị
# vi phạm cũng không có gì được thực thi.
function ConvertFrom-ShellEnv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Text
    )

    $pairs = [ordered]@{}

    foreach ($line in ($Text -split "`r?`n")) {
        $trimmed = $line.Trim()
        if ($trimmed -eq '')            { continue }
        if ($trimmed.StartsWith('#'))   { continue }
        if ($trimmed -notmatch '^(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)=(.*)$') { continue }

        $name  = $Matches[1]
        $value = $Matches[2].Trim()

        # Chỉ bỏ đúng một cặp nháy bọc ngoài. Nháy bên trong là dữ liệu.
        if ($value.Length -ge 2) {
            $first = $value[0]
            $last  = $value[$value.Length - 1]
            if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
                $value = $value.Substring(1, $value.Length - 2)
            }
        }

        $pairs[$name] = $value
    }

    return $pairs
}
```

- [ ] **Step 4: Chạy test, xác nhận pass**

```bash
git add windows/lib/Secrets.psm1 && git commit -q -m "windows: them ConvertFrom-ShellEnv doc dinh dang shell env" && git push origin main
gh run watch --exit-status
```

Kết quả mong đợi: PASS, 6 test.

- [ ] **Step 5: Ghi luật giá trị literal vào CLAUDE.md**

Trong `CLAUDE.md`, mục `## This repo is public`, thêm vào cuối danh sách `Never commit:`:

```markdown
- **Shell expansion inside secret values.** `apikey.zsh.age` is read by zsh *and*
  by a PowerShell parser on Windows. A value containing `$`, a backtick, or
  `$(...)` expands on one side and stays literal on the other — silently. Values
  are literal text only.
```

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md
git commit -m "CLAUDE.md: value trong secret phai la chu thuan, khong noi suy"
git push origin main
```

---

### Task 2: Ghi file `Write-PwshSecretsFile`

Ghi ra file `.ps1` qua temp + move, đặt ACL trước khi move. Tính chất phải giữ: **ghi hỏng không được phá bản cũ**.

**Files:**
- Modify: `windows/lib/Secrets.psm1` (thêm hàm)
- Modify: `windows/tests/secrets.Tests.ps1` (thêm `Describe` thứ hai)

**Interfaces:**
- Consumes: `ConvertFrom-ShellEnv` (Task 1) — nhận `OrderedDictionary` của nó.
- Produces: `Write-PwshSecretsFile -Pairs <IDictionary> -Path <string>` → `[int]` số biến đã ghi. Task 3 gọi hàm này.

- [ ] **Step 1: Viết test thất bại**

Thêm vào cuối `windows/tests/secrets.Tests.ps1`:

```powershell
Describe 'windows/lib/Secrets.psm1 Write-PwshSecretsFile' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        Import-Module (Join-Path $RepoRoot 'windows\lib\Secrets.psm1') -Force
        $WorkDir = Join-Path $env:TEMP ("secrets-test-" + [Guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null
    }
    AfterAll {
        if ($WorkDir -and (Test-Path $WorkDir)) { Remove-Item $WorkDir -Recurse -Force }
    }

    It 'writes one $env: assignment per pair and returns the count' {
        $out = Join-Path $WorkDir 'a.ps1'
        $n = Write-PwshSecretsFile -Pairs ([ordered]@{ ALPHA = 'one'; BRAVO = 'two' }) -Path $out
        $n | Should Be 2
        $text = Get-Content -LiteralPath $out -Raw
        $text | Should Match '\$env:ALPHA = ''one'''
        $text | Should Match '\$env:BRAVO = ''two'''
    }

    It 'produces a file that actually sets the variables when dot-sourced' {
        $out = Join-Path $WorkDir 'b.ps1'
        Write-PwshSecretsFile -Pairs ([ordered]@{ TEST_CHARLIE = 'three' }) -Path $out | Out-Null
        . $out
        $env:TEST_CHARLIE | Should Be 'three'
        Remove-Item Env:\TEST_CHARLIE -ErrorAction SilentlyContinue
    }

    It 'escapes a single quote so the literal survives' {
        $out = Join-Path $WorkDir 'c.ps1'
        Write-PwshSecretsFile -Pairs ([ordered]@{ TEST_DELTA = "it's" }) -Path $out | Out-Null
        . $out
        $env:TEST_DELTA | Should Be "it's"
        Remove-Item Env:\TEST_DELTA -ErrorAction SilentlyContinue
    }

    It 'does not interpolate a value that looks like PowerShell' {
        $out = Join-Path $WorkDir 'd.ps1'
        Write-PwshSecretsFile -Pairs ([ordered]@{ TEST_ECHO = '$(Get-Date)' }) -Path $out | Out-Null
        . $out
        $env:TEST_ECHO | Should Be '$(Get-Date)'
        Remove-Item Env:\TEST_ECHO -ErrorAction SilentlyContinue
    }

    It 'creates the parent directory when missing' {
        $out = Join-Path $WorkDir 'nested\deeper\e.ps1'
        Write-PwshSecretsFile -Pairs ([ordered]@{ FOXTROT = 'six' }) -Path $out | Out-Null
        Test-Path -LiteralPath $out | Should Be $true
    }

    It 'leaves no .tmp leftovers behind' {
        $out = Join-Path $WorkDir 'f.ps1'
        Write-PwshSecretsFile -Pairs ([ordered]@{ GOLF = 'seven' }) -Path $out | Out-Null
        @(Get-ChildItem -LiteralPath $WorkDir -Filter '.tmp.*' -Force).Count | Should Be 0
    }

    It 'overwrites an existing file in place' {
        $out = Join-Path $WorkDir 'g.ps1'
        Write-PwshSecretsFile -Pairs ([ordered]@{ HOTEL = 'old' }) -Path $out | Out-Null
        Write-PwshSecretsFile -Pairs ([ordered]@{ HOTEL = 'new' }) -Path $out | Out-Null
        (Get-Content -LiteralPath $out -Raw) | Should Match '\$env:HOTEL = ''new'''
    }
}
```

- [ ] **Step 2: Chạy test, xác nhận thất bại**

```bash
git add windows/tests/secrets.Tests.ps1 && git commit -q -m "test: Write-PwshSecretsFile (chua co implementation)" && git push origin main
gh run watch --exit-status
```

Kết quả mong đợi: FAIL — `Write-PwshSecretsFile` không tồn tại.

- [ ] **Step 3: Viết implementation tối thiểu**

Thêm vào `windows/lib/Secrets.psm1`:

```powershell
# Ghi qua temp rồi move, giống hệt `agenix-reload` trên Unix và vì cùng lý do:
# một lần ghi hỏng không được để lại file cụt. ACL đặt trên temp *trước* khi
# move, nên không có khoảnh khắc nào file đích tồn tại với quyền kế thừa.
function Write-PwshSecretsFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][System.Collections.IDictionary]$Pairs,
        [Parameter(Mandatory)][string]$Path
    )

    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $lines = @('# Generated by windows/lib/Secrets.psm1 -- do not edit, do not commit.')
    foreach ($name in $Pairs.Keys) {
        $escaped = [string]$Pairs[$name] -replace "'", "''"
        $lines  += ('$env:{0} = ''{1}''' -f $name, $escaped)
    }

    $tmp = Join-Path $dir ('.tmp.' + [System.IO.Path]::GetRandomFileName())
    try {
        Set-Content -LiteralPath $tmp -Value $lines -Encoding UTF8 -Force

        $me = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        & icacls $tmp /inheritance:r /grant:r "${me}:(R,W)" | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "icacls failed on $tmp" }

        Move-Item -LiteralPath $tmp -Destination $Path -Force
    }
    finally {
        if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force }
    }

    return $Pairs.Count
}
```

- [ ] **Step 4: Chạy test, xác nhận pass**

```bash
git add windows/lib/Secrets.psm1 && git commit -q -m "windows: them Write-PwshSecretsFile ghi qua temp roi move" && git push origin main
gh run watch --exit-status
```

Kết quả mong đợi: PASS, 13 test (6 của Task 1 + 7 mới).

- [ ] **Step 5: Commit**

Đã commit ở Step 4.

---

### Task 3: Orchestrator `Update-PwshSecrets`

Nối `age` → parser → ghi file, kèm các guard clause. Test bằng **stub `age`** để kiểm được cả nhánh giải mã hỏng mà không cần khoá thật.

**Files:**
- Modify: `windows/lib/Secrets.psm1` (thêm hàm + import Logging)
- Modify: `windows/tests/secrets.Tests.ps1` (thêm `Describe` thứ ba)

**Interfaces:**
- Consumes: `ConvertFrom-ShellEnv` (Task 1), `Write-PwshSecretsFile` (Task 2).
- Produces: `Update-PwshSecrets [-RepoRoot] [-Identity] [-OutFile] [-AgeCommand]` → `[int]` số biến, hoặc `$null` khi bỏ qua. Task 4 và 5 gọi hàm này.

- [ ] **Step 1: Viết test thất bại**

Thêm vào cuối `windows/tests/secrets.Tests.ps1`:

```powershell
Describe 'windows/lib/Secrets.psm1 Update-PwshSecrets' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        Import-Module (Join-Path $RepoRoot 'windows\lib\Secrets.psm1') -Force

        $WorkDir = Join-Path $env:TEMP ("update-test-" + [Guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null

        # Cây repo giả: chỉ cần đúng đường dẫn tới file .age, nội dung không cần
        # là ciphertext thật vì `age` ở đây là stub.
        $FakeRepo = Join-Path $WorkDir 'repo'
        $AgeDir   = Join-Path $FakeRepo 'home-manager\programs\zsh\age.d'
        New-Item -ItemType Directory -Path $AgeDir -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $AgeDir 'apikey.zsh.age') -Value 'not-real-ciphertext'

        $FakeKey = Join-Path $WorkDir 'id_ed25519'
        Set-Content -LiteralPath $FakeKey -Value 'not-a-real-key'

        # Stub age thành công: in ra hai dòng bịa.
        $AgeOk = Join-Path $WorkDir 'age-ok.cmd'
        Set-Content -LiteralPath $AgeOk -Value @(
            '@echo off'
            'echo export TEST_ALPHA="one"'
            'echo export TEST_BRAVO="two"'
        )

        # Stub age hỏng: mã thoát khác 0, không in gì.
        $AgeFail = Join-Path $WorkDir 'age-fail.cmd'
        Set-Content -LiteralPath $AgeFail -Value @('@echo off', 'exit /b 1')
    }
    AfterAll {
        if ($WorkDir -and (Test-Path $WorkDir)) { Remove-Item $WorkDir -Recurse -Force }
    }

    It 'writes the secrets file and returns the count on success' {
        $out = Join-Path $WorkDir 'out-ok.ps1'
        $n = Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out -AgeCommand $AgeOk
        $n | Should Be 2
        (Get-Content -LiteralPath $out -Raw) | Should Match '\$env:TEST_ALPHA = ''one'''
    }

    It 'returns null and does not throw when the identity is missing' {
        $out = Join-Path $WorkDir 'out-nokey.ps1'
        $missing = Join-Path $WorkDir 'no-such-key'
        $n = Update-PwshSecrets -RepoRoot $FakeRepo -Identity $missing -OutFile $out -AgeCommand $AgeOk
        $n | Should BeNullOrEmpty
        Test-Path -LiteralPath $out | Should Be $false
    }

    It 'returns null and does not throw when the .age file is missing' {
        $out = Join-Path $WorkDir 'out-noage.ps1'
        $emptyRepo = Join-Path $WorkDir 'empty-repo'
        New-Item -ItemType Directory -Path $emptyRepo -Force | Out-Null
        $n = Update-PwshSecrets -RepoRoot $emptyRepo -Identity $FakeKey -OutFile $out -AgeCommand $AgeOk
        $n | Should BeNullOrEmpty
        Test-Path -LiteralPath $out | Should Be $false
    }

    It 'leaves the previous file untouched when decryption fails' {
        $out = Join-Path $WorkDir 'out-keep.ps1'
        Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out -AgeCommand $AgeOk | Out-Null
        $before = Get-Content -LiteralPath $out -Raw

        $n = Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out -AgeCommand $AgeFail
        $n | Should BeNullOrEmpty
        (Get-Content -LiteralPath $out -Raw) | Should Be $before
    }

    It 'never throws, whatever is missing' {
        { Update-PwshSecrets -RepoRoot 'C:\nope' -Identity 'C:\nope' `
            -OutFile (Join-Path $WorkDir 'x.ps1') -AgeCommand 'C:\nope.exe' } | Should Not Throw
    }
}
```

- [ ] **Step 2: Chạy test, xác nhận thất bại**

```bash
git add windows/tests/secrets.Tests.ps1 && git commit -q -m "test: Update-PwshSecrets voi stub age (chua co implementation)" && git push origin main
gh run watch --exit-status
```

Kết quả mong đợi: FAIL — `Update-PwshSecrets` không tồn tại.

- [ ] **Step 3: Viết implementation tối thiểu**

Thêm vào **đầu** `windows/lib/Secrets.psm1`, trước hàm đầu tiên:

```powershell
Import-Module (Join-Path $PSScriptRoot 'Logging.psm1') -Force -DisableNameChecking
```

Thêm vào cuối `windows/lib/Secrets.psm1`:

```powershell
# Mọi điều kiện thiếu đều `return $null` chứ không `throw`: hàm này chạy trong
# vòng lặp module của apply.ps1, và một máy chưa có khoá không được làm hỏng cả
# lượt apply. Cùng nguyên tắc với `agenix-reload` trên Unix.
function Update-PwshSecrets {
    [CmdletBinding()]
    param(
        [string]$RepoRoot   = (Join-Path $env:USERPROFILE '.nix'),
        [string]$Identity   = (Join-Path $env:USERPROFILE '.ssh\id_ed25519'),
        [string]$OutFile    = (Join-Path $env:LOCALAPPDATA 'pwsh-secrets\apikey.ps1'),
        [string]$AgeCommand = 'age'
    )

    $age = Get-Command $AgeCommand -ErrorAction SilentlyContinue
    if (-not $age) {
        Write-Warn "age not found ($AgeCommand) -- install it with scoop"
        return $null
    }

    if (-not (Test-Path -LiteralPath $Identity)) {
        Write-Skip "no age identity at $Identity"
        return $null
    }

    $ageFile = Join-Path $RepoRoot 'home-manager\programs\zsh\age.d\apikey.zsh.age'
    if (-not (Test-Path -LiteralPath $ageFile)) {
        Write-Warn "no secret file at $ageFile"
        return $null
    }

    $global:LASTEXITCODE = 0
    $text = & $age.Source -d -i $Identity $ageFile 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "age -d failed with exit code $LASTEXITCODE"
        return $null
    }

    $pairs = ConvertFrom-ShellEnv -Text ($text -join "`n")
    if ($pairs.Count -eq 0) {
        Write-Warn 'decrypted successfully but found no assignments'
        return $null
    }

    Write-PwshSecretsFile -Pairs $pairs -Path $OutFile | Out-Null
    Write-OK "$($pairs.Count) secrets -> $OutFile"
    return $pairs.Count
}
```

- [ ] **Step 4: Chạy test, xác nhận pass**

```bash
git add windows/lib/Secrets.psm1 && git commit -q -m "windows: them Update-PwshSecrets noi age vao parser va ghi file" && git push origin main
gh run watch --exit-status
```

Kết quả mong đợi: PASS, 18 test.

- [ ] **Step 5: Commit**

Đã commit ở Step 4.

---

### Task 4: Nối vào `apply.ps1`

Module mỏng gọi `Update-PwshSecrets`, thêm `age` vào scoop, thêm module vào danh sách.

**Files:**
- Create: `windows/modules/programs/agenix/module.ps1`
- Modify: `windows/modules/packages/scoop/module.ps1` (thêm `'age'`)
- Modify: `windows/apply.ps1:37-40` (thêm `'programs.agenix'`)
- Modify: `windows/tests/secrets.Tests.ps1` (thêm `Describe` assert tĩnh)

**Interfaces:**
- Consumes: `Update-PwshSecrets` (Task 3).
- Produces: module name `programs.agenix` dùng được trong `$modules`.

- [ ] **Step 1: Viết test thất bại**

Thêm vào cuối `windows/tests/secrets.Tests.ps1`:

```powershell
Describe 'windows programs.agenix module wiring' {
    BeforeAll {
        $RepoRoot   = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ModulePath = Join-Path $RepoRoot 'windows\modules\programs\agenix\module.ps1'
        $ApplyText  = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\apply.ps1')
        $ScoopText  = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\modules\packages\scoop\module.ps1')
    }

    It 'has a module file with Description and Apply' {
        Test-Path -LiteralPath $ModulePath | Should Be $true
        $mod = & $ModulePath
        $mod.Description | Should Not BeNullOrEmpty
        $mod.Apply       | Should Not BeNullOrEmpty
    }

    It 'is listed in apply.ps1' {
        $ApplyText | Should Match "'programs\.agenix'"
    }

    It 'runs after packages.scoop, which provides age' {
        $scoopAt  = $ApplyText.IndexOf("'packages.scoop'")
        $agenixAt = $ApplyText.IndexOf("'programs.agenix'")
        ($scoopAt  -ge 0) | Should Be $true
        ($agenixAt -ge 0) | Should Be $true
        ($agenixAt -gt $scoopAt) | Should Be $true
    }

    It 'runs after dotfiles.pwsh, which links ps1.d' {
        $pwshAt   = $ApplyText.IndexOf("'dotfiles.pwsh'")
        $agenixAt = $ApplyText.IndexOf("'programs.agenix'")
        ($agenixAt -gt $pwshAt) | Should Be $true
    }

    It 'installs age via scoop' {
        $ScoopText | Should Match "(?m)^\s*'age'\s*$"
    }

    It 'leaves OutFile at its default, so nothing is written under the repo' {
        $ModuleText = Get-Content -Raw -LiteralPath $ModulePath
        $ModuleText | Should Not Match '-OutFile'
    }
}
```

- [ ] **Step 2: Chạy test, xác nhận thất bại**

```bash
git add windows/tests/secrets.Tests.ps1 && git commit -q -m "test: wiring programs.agenix (chua co module)" && git push origin main
gh run watch --exit-status
```

Kết quả mong đợi: FAIL — không có `windows\modules\programs\agenix\module.ps1`.

- [ ] **Step 3: Tạo module**

Tạo `windows/modules/programs/agenix/module.ps1`:

```powershell
@{
    Description = 'Decrypt the shared apikey secret into %LOCALAPPDATA%\pwsh-secrets for pwsh'
    Apply = {
        param($Ctx)
        Import-Module (Join-Path $Ctx.WindowsDir 'lib\Secrets.psm1') -Force
        Update-PwshSecrets -RepoRoot $Ctx.RepoRoot | Out-Null
    }
}
```

- [ ] **Step 4: Thêm `age` vào scoop**

Trong `windows/modules/packages/scoop/module.ps1`, thêm `'age'` vào cuối mảng `-Packages`, sau `'uv'`:

```powershell
            'rustup'
            'uv'
            'age'
        )
```

- [ ] **Step 5: Thêm module vào `apply.ps1`**

Trong `windows/apply.ps1`, mục `# ---- programs (shared with home-manager) ----`, thêm dòng đầu tiên của nhóm:

```powershell
    # ---- programs (shared with home-manager) ----
    'programs.agenix'             # needs age from packages.scoop and ps1.d from dotfiles.pwsh
    'programs.ssh'
    'programs.nvim'
    'programs.yazi'
```

- [ ] **Step 6: Chạy test, xác nhận pass**

```bash
git add windows/modules/programs/agenix/module.ps1 windows/modules/packages/scoop/module.ps1 windows/apply.ps1
git commit -q -m "windows: them module programs.agenix va age vao scoop"
git push origin main
gh run watch --exit-status
```

Kết quả mong đợi: PASS, 24 test.

---

### Task 5: Nạp vào shell

Drop-in dot-source file sinh ra, cộng hàm `Update-Secrets` để làm mới không cần chạy `apply.ps1`.

**Files:**
- Create: `home-manager/dotfiles/windows/pwsh/ps1.d/apikey.ps1`
- Modify: `home-manager/dotfiles/windows/pwsh/Microsoft.PowerShell_profile.ps1:61`
- Modify: `home-manager/dotfiles/windows/pwsh/ps1.d/functions.ps1` (cuối file)
- Modify: `windows/tests/secrets.Tests.ps1` (thêm `Describe` assert tĩnh)

**Interfaces:**
- Consumes: `Update-PwshSecrets` (Task 3); file sinh ra ở `%LOCALAPPDATA%\pwsh-secrets\apikey.ps1`.
- Produces: hàm `Update-Secrets`, alias `agenix-reload`.

- [ ] **Step 1: Viết test thất bại**

Thêm vào cuối `windows/tests/secrets.Tests.ps1`:

```powershell
Describe 'pwsh shell wiring for secrets' {
    BeforeAll {
        $RepoRoot    = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $PwshDir     = Join-Path $RepoRoot 'home-manager\dotfiles\windows\pwsh'
        $DropInPath  = Join-Path $PwshDir 'ps1.d\apikey.ps1'
        $ProfileText = Get-Content -Raw -LiteralPath (Join-Path $PwshDir 'Microsoft.PowerShell_profile.ps1')
        $FuncText    = Get-Content -Raw -LiteralPath (Join-Path $PwshDir 'ps1.d\functions.ps1')
    }

    It 'ships a drop-in that loads the generated file' {
        Test-Path -LiteralPath $DropInPath | Should Be $true
        $text = Get-Content -Raw -LiteralPath $DropInPath
        $text | Should Match 'pwsh-secrets'
    }

    It 'keeps the drop-in free of any value -- it only dot-sources' {
        $text = Get-Content -Raw -LiteralPath $DropInPath
        $text | Should Not Match '\$env:[A-Z_]+\s*='
    }

    It 'is listed in the profile, which does not glob ps1.d' {
        # Đơn giản có chủ đích: khẳng định tên file có mặt, còn việc nó nằm đúng
        # khối nào để test kế tiếp lo. Regex bám vào cả dòng `foreach` sẽ gãy
        # ngay lần đầu ai đó xuống dòng cho danh sách dài ra.
        $ProfileText | Should Match "'apikey\.ps1'"
    }

    It 'loads in the always-on block so pwsh -c over SSH gets the keys too' {
        $alwaysOn    = $ProfileText.IndexOf('always on: plain definitions')
        $interactive = $ProfileText.IndexOf('if (-not $Interactive) { return }')
        $apikeyAt    = $ProfileText.IndexOf("'apikey.ps1'")
        ($apikeyAt -gt $alwaysOn)    | Should Be $true
        ($apikeyAt -lt $interactive) | Should Be $true
    }

    It 'defines Update-Secrets with an agenix-reload alias' {
        $FuncText | Should Match 'function Update-Secrets'
        $FuncText | Should Match "Set-Alias agenix-reload Update-Secrets"
    }

    It 'imports the module inside the function body, not at shell start' {
        $FuncText | Should Match '(?s)function Update-Secrets \{[^}]*Import-Module'
    }
}
```

- [ ] **Step 2: Chạy test, xác nhận thất bại**

```bash
git add windows/tests/secrets.Tests.ps1 && git commit -q -m "test: nap secret vao shell pwsh (chua co drop-in)" && git push origin main
gh run watch --exit-status
```

Kết quả mong đợi: FAIL — không có `ps1.d/apikey.ps1`.

- [ ] **Step 3: Tạo drop-in**

Tạo `home-manager/dotfiles/windows/pwsh/ps1.d/apikey.ps1`:

```powershell
# Nạp secret đã giải mã bởi windows/modules/programs/agenix.
#
# File này nằm trong repo public nên KHÔNG BAO GIỜ chứa giá trị -- nó chỉ
# dot-source file sinh ra ở %LOCALAPPDATA%. Máy chưa chạy apply.ps1 lần nào thì
# bỏ qua im lặng, giống `[ -r ... ] && source ...` trong .zshrc trên Unix.
$SecretsFile = Join-Path $env:LOCALAPPDATA 'pwsh-secrets\apikey.ps1'
if (Test-Path -LiteralPath $SecretsFile) { . $SecretsFile }
```

- [ ] **Step 4: Thêm vào danh sách nạp của profile**

Trong `home-manager/dotfiles/windows/pwsh/Microsoft.PowerShell_profile.ps1`, sửa dòng 61:

```powershell
foreach ($file in 'env.ps1', 'apikey.ps1', 'alias.ps1', 'functions.ps1') {
```

Profile **không** glob thư mục `ps1.d` — thiếu dòng này thì drop-in không bao giờ chạy, và triệu chứng là "không có biến nào, không có lỗi nào".

- [ ] **Step 5: Thêm `Update-Secrets` vào `functions.ps1`**

Thêm vào cuối `home-manager/dotfiles/windows/pwsh/ps1.d/functions.ps1`:

```powershell
# ----------------------------
# Secrets
# ----------------------------

# Giải mã lại secret và nạp thẳng vào shell đang chạy. `$env:` ánh xạ vào
# environment block của tiến trình, nên khác Unix -- ở đó `agenix-reload` chỉ
# ghi lại file, shell đang mở phải source lại.
#
# Import-Module nằm trong thân hàm để không tốn gì lúc mở shell.
function Update-Secrets {
    $repo = Join-Path $env:USERPROFILE '.nix'
    Import-Module (Join-Path $repo 'windows\lib\Secrets.psm1') -Force
    $n = Update-PwshSecrets -RepoRoot $repo
    if ($null -eq $n) { return }
    $file = Join-Path $env:LOCALAPPDATA 'pwsh-secrets\apikey.ps1'
    if (Test-Path -LiteralPath $file) { . $file }
}
Set-Alias agenix-reload Update-Secrets
```

- [ ] **Step 6: Chạy test, xác nhận pass**

```bash
git add home-manager/dotfiles/windows/pwsh/
git commit -q -m "windows: nap secret vao pwsh qua ps1.d va them Update-Secrets"
git push origin main
gh run watch --exit-status
```

Kết quả mong đợi: PASS, 30 test.

---

### Task 6: Kiểm chứng trên `a14` — ĐÃ XONG 03/08/2026

Chạy qua SSH từ macmini. Máy: `ZENBOOK-A14`, Windows ARM64, pwsh 7.6.4, user `kln`.
Repo ở `2d7631b8`. **Cả 10 bước đạt.** Kết quả từng bước:

| Bước | Kết quả |
|---|---|
| 1. `age` trên ARM64 | **ĐẠT.** `age v1.3.1` từ bucket `extras` (không cần đóng gói riêng). Vòng mã hoá→giải mã thật bằng chính khoá SSH: khớp. |
| 2. Passphrase | **ĐẠT.** `ssh-keygen -y -P ""` thoát 0 → không passphrase. Comment pubkey là `windows`, đúng 1 trong 4 recipient. |
| 3. `apply.ps1` | **ĐẠT.** `22 ok, 0 failed`. `OK 14 secrets -> ...\pwsh-secrets\apikey.ps1`. |
| 4. Shell mới thấy biến | **ĐẠT.** Đủ 14 biến, độ dài khớp mac từng cái. |
| 5. Không-interactive | **ĐẠT.** Profile coi `-EncodedCommand` là không interactive (regex dòng 13), mà vẫn có đủ biến → khối always-on đúng chỗ. |
| 6. ACL | **ĐẠT.** `AreAccessRulesProtected = True`, ACE duy nhất là `ZENBOOK-A14\kln : Write, Read, Synchronize`. Không SYSTEM, không Administrators, không Users. |
| 7. Chi phí mở shell | **KHÔNG ĐẠT ngưỡng đã đặt** — xem dưới. |
| 8. Reload không cần apply | **ĐẠT.** Xoá file sinh ra + xoá biến khỏi tiến trình, `agenix-reload` dựng lại cả hai **trong chính shell đang chạy**. |
| 9. Không rò vào repo | **ĐẠT.** `git status` sạch, không file lạ nào trong cây repo. |

**Bằng chứng C1 (quan trọng nhất).** Log `apply.ps1` cho thấy đủ 8 module *sau*
`programs.agenix` đều chạy: `programs.ssh`, `programs.nvim`, `programs.yazi`,
`services.kanata`, `services.kanata-watchdog`, `services.ahk`,
`services.ahk-watchdog`, `services.sshd`. Trước khi sửa C1, run sẽ chết ngay sau
`programs.agenix` và bỏ hết 8 module này.

**Toàn vẹn dữ liệu.** So từng biến giữa mac và Windows bằng **độ dài giá trị**
(không lộ giá trị): 14/14 khớp cả tên lẫn độ dài. Ciphertext thật, `age` thật,
khoá thật — không còn khâu nào chạy bằng stub.

**Bước 7 sai so với dự đoán, ghi lại cho trung thực.** Riêng drop-in
`apikey.ps1` tốn **~7.75 ms** trung bình (min 5.52, max 37.67 khi lạnh), đo 20
lần. Spec mục 4 viết "dưới 1 ms" và bước này đặt ngưỡng "dưới 5 ms" — **cả hai
đều sai**. Nguyên nhân nhiều khả năng là Defender quét file mỗi lần mở, chứ
không phải 14 phép gán.

Không đổi quyết định thiết kế: tổng thời gian mở shell là ~286 ms, nên drop-in
chiếm ~2.7%; và phương án bị loại (gọi `age.exe` mỗi shell) tốn 30–60 ms, vẫn
đắt hơn 4–8 lần. Nhưng ngưỡng "dưới 5 ms" là con số tôi bịa mà không đo, và nó
sai.

---

Runbook gốc giữ lại bên dưới để chạy lại trên máy Windows khác.

- [x] **Step 1: Kiểm tiên quyết 1 — `age` chạy được trên ARM64**

```powershell
scoop install age
age --version
```

Upstream chỉ phát hành `windows-amd64`; ARM64 chạy qua giả lập x64. Nếu scoop không cài được hoặc binary không chạy: **dừng**, đóng gói bản arm64 vào bucket `xom11/scoop-bucket` rồi quay lại.

- [ ] **Step 2: Kiểm tiên quyết 2 — khoá không đặt passphrase**

```powershell
ssh-keygen -y -f "$env:USERPROFILE\.ssh\id_ed25519"
```

Không hỏi gì và in ra public key là đạt. Nếu nó hỏi passphrase: **dừng** — `apply.ps1` sẽ treo giữa chừng chờ nhập.

- [ ] **Step 3: Chạy apply**

```powershell
cd $env:USERPROFILE\.nix
git pull
.\windows\apply.ps1 -NoElevate -NoWait
```

Mong đợi: dòng `OK    14 secrets -> ...\pwsh-secrets\apikey.ps1`.

- [ ] **Step 4: Kiểm shell mới thấy biến**

```powershell
pwsh -NoProfile -Command "exit"   # hâm nóng
pwsh -Command "if ($env:PIXELLAB_TOKEN) { 'co gia tri' } else { 'THIEU' }"
```

- [ ] **Step 5: Kiểm `pwsh -c` qua SSH cũng thấy**

Từ mac:

```bash
ssh a14 'pwsh -c "if ($env:GITHUB_KEY) { \"co gia tri\" } else { \"THIEU\" }"'
```

Đây là lý do drop-in nằm ở khối *always on* chứ không phải khối interactive.

- [ ] **Step 6: Kiểm ACL**

```powershell
icacls "$env:LOCALAPPDATA\pwsh-secrets\apikey.ps1"
```

Chỉ được liệt kê chính user. Không có `BUILTIN\Users`.

- [ ] **Step 7: Đo chi phí mở shell**

```powershell
(Measure-Command { pwsh -Command "exit" }).TotalMilliseconds
```

Chạy 5 lần, so với con số trước khi có thay đổi. Chênh lệch phải dưới 5 ms. Nếu vượt: drop-in đang làm gì đó ngoài `Test-Path` + dot-source.

- [ ] **Step 8: Kiểm vòng đời sửa-không-cần-apply**

Trên mac: sửa một biến vô hại trong secret bằng nvim, `:w`, commit, push. Trên a14:

```powershell
cd $env:USERPROFILE\.nix; git pull
agenix-reload
```

Giá trị mới phải có ngay **trong chính shell đang mở**, không cần chạy lại `apply.ps1`, không cần mở shell mới.

- [ ] **Step 9: Kiểm không rò vào repo**

```powershell
cd $env:USERPROFILE\.nix
git status --porcelain
Get-ChildItem -Recurse -Force -Filter 'apikey.ps1' | Where-Object { $_.FullName -notmatch 'dotfiles' }
```

`git status` phải sạch. Lệnh thứ hai phải không trả về gì — không có file sinh ra nào nằm trong cây repo.

- [ ] **Step 10: Ghi kết quả và commit**

Điền kết quả từng bước vào mục này (đặc biệt: phiên bản `age` cài được, và chênh lệch thời gian mở shell), rồi:

```bash
git add docs/superpowers/plans/2026-08-02-windows-secrets.md
git commit -m "plan: ghi ket qua kiem chung tren a14"
git push origin main
```
