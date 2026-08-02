# apply.ps1 import Logging.psm1 vào session toàn cục rồi mới chạy vòng lặp module,
# và `programs.agenix` import Secrets.psm1 từ bên trong vòng lặp đó. Nếu
# Secrets.psm1 import Logging.psm1 kèm `-Force`, `-Force` chạy Remove-Module trước
# -- binding toàn cục bị xoá, còn bản import lại rơi vào session state riêng của
# Secrets. Hệ quả: `Write-Section` ở đầu vòng lặp kế tiếp (nằm NGOÀI try trong
# cùng) ném CommandNotFoundException lên try ngoài, apply.ps1 in một dòng lỗi trần
# rồi exit 1, và 8 module còn lại -- programs.ssh/nvim/yazi, services.kanata*,
# services.ahk*, services.sshd -- không bao giờ chạy. services.sshd chính là thứ
# giữ đường SSH vào máy đó.
#
# Describe này đứng đầu file có chủ đích: nó phải chạy trước các Describe khác,
# vốn tự import Logging lại và vô tình vá hỏng hóc đi.
Describe 'windows/lib/Secrets.psm1 import hygiene' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    }

    It 'leaves the caller''s Logging bindings alive after Secrets.psm1 is imported' {
        Import-Module (Join-Path $RepoRoot 'windows\lib\Logging.psm1') -Force -DisableNameChecking
        (Get-Command Write-Section -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty

        Import-Module (Join-Path $RepoRoot 'windows\lib\Secrets.psm1') -Force
        (Get-Command Write-Section -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty

        # Import lần hai: apply.ps1 + Update-Secrets trong cùng một tiến trình.
        Import-Module (Join-Path $RepoRoot 'windows\lib\Secrets.psm1') -Force
        (Get-Command Write-Section -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        (Get-Command Write-Fail    -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
    }

    # Mặt còn lại của cùng một ràng buộc: bỏ hẳn dòng Import-Module cũng sai, vì
    # Update-Secrets và test import Secrets.psm1 độc lập, không có Logging sẵn.
    # Chạy trong tiến trình con để session hiện tại (đã có Logging) không che mất.
    It 'still resolves its own logging helpers when imported into a bare session' {
        $lib    = Join-Path $RepoRoot 'windows\lib\Secrets.psm1'
        $script = Join-Path $env:TEMP ("secrets-bare-" + [Guid]::NewGuid().ToString('N') + '.ps1')
        Set-Content -LiteralPath $script -Value @(
            "`$ErrorActionPreference = 'Stop'"
            "Import-Module '$lib'"
            "Update-PwshSecrets -RepoRoot 'C:\nope' -Identity 'C:\nope' -OutFile 'C:\nope\out.ps1' -AgeCommand 'C:\nope.exe' | Out-Null"
            "'BARE-SESSION-OK'"
        )
        try {
            $out = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $script 2>&1
            $global:LASTEXITCODE = 0
            ($out -join "`n") | Should Match 'BARE-SESSION-OK'
        }
        finally {
            Remove-Item -LiteralPath $script -Force -ErrorAction SilentlyContinue
        }
    }
}

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

    # LƯU Ý: khẳng định dưới đây ghi lại một GIỚI HẠN đã biết, không phải một
    # hành vi đúng. Parser này cố tình đơn giản -- bóc đúng một cặp nháy bọc
    # ngoài, phần còn lại là dữ liệu. zsh thì ghép các từ nháy liền nhau, nên
    # cùng dòng này zsh cho `say hi` còn ở đây cho `say ""hi""`. Tương tự,
    # `export K='it'\''s'` zsh cho `it's` còn ở đây cho literal `it'\''s`.
    # Làm parser tương thích hoàn toàn với shell là không đáng; thay vào đó
    # CLAUDE.md cấm hẳn `'` và `"` bên trong value, nên không value hợp lệ nào
    # đi qua nhánh này. Nếu ngày nào đó cần chứa nháy thật, phải sửa parser
    # trước -- đừng nới luật rồi trông chờ test này bảo là ổn.
    It 'documents the known divergence from zsh on inner quotes (limitation, not parity)' {
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

    It 'leaves no backup of the previous secret values after a successful overwrite' {
        $out = Join-Path $WorkDir 'g2.ps1'
        Write-PwshSecretsFile -Pairs ([ordered]@{ JULIET = 'old-secret' }) -Path $out | Out-Null
        Write-PwshSecretsFile -Pairs ([ordered]@{ JULIET = 'new-secret' }) -Path $out | Out-Null
        @(Get-ChildItem -LiteralPath $WorkDir -Filter '.tmp.*' -Force).Count | Should Be 0
    }

    It 'leaves the previous file intact and reports failure loudly when the replace is blocked' {
        $out = Join-Path $WorkDir 'h.ps1'
        Write-PwshSecretsFile -Pairs ([ordered]@{ INDIA = 'old' }) -Path $out | Out-Null
        $before = Get-Content -LiteralPath $out -Raw

        $handle = [System.IO.File]::Open($out, 'Open', 'ReadWrite', 'None')
        try {
            { Write-PwshSecretsFile -Pairs ([ordered]@{ INDIA = 'new' }) -Path $out } | Should Throw
        }
        finally {
            $handle.Close()
        }

        (Get-Content -LiteralPath $out -Raw) | Should Be $before
        @(Get-ChildItem -LiteralPath $WorkDir -Filter '.tmp.*' -Force).Count | Should Be 0
    }

    It 'installs the file with a non-inherited ACL granting nobody but the current user' {
        $out = Join-Path $WorkDir 'acl-first.ps1'
        Write-PwshSecretsFile -Pairs ([ordered]@{ KILO = 'nine' }) -Path $out | Out-Null

        $acl = Get-Acl -LiteralPath $out
        $acl.AreAccessRulesProtected | Should Be $true

        $ids = @($acl.Access | ForEach-Object { $_.IdentityReference.Value })
        ($ids -contains 'BUILTIN\Users') | Should Be $false
        ($ids -contains 'Everyone')      | Should Be $false

        # Không hardcode tên tài khoản: runner Actions dùng tên khác máy thật.
        $me = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        @($ids | Where-Object { $_ -ne $me }).Count | Should Be 0
    }

    # Đường ghi đè đi qua ReplaceFileW, và ReplaceFileW mang DACL của file BỊ THAY
    # THẾ sang file thay thế -- ACL đặt trên temp bị vứt đi. Nên nếu file đích
    # từng tồn tại với quyền kế thừa (khôi phục từ backup, copy từ máy khác, tạo
    # tay lúc debug), mọi lần apply/Update-Secrets sau đó sẽ giữ nguyên quyền rộng
    # đó mà vẫn báo "OK 14 secrets". Không có gì phát hiện ra.
    It 'reapplies the restrictive ACL on the overwrite path, not just on first write' {
        $out = Join-Path $WorkDir 'acl-overwrite.ps1'

        # Tạo tay -> kế thừa quyền của thư mục cha. Đây là tiền đề của test.
        Set-Content -LiteralPath $out -Value '# placeholder'
        (Get-Acl -LiteralPath $out).AreAccessRulesProtected | Should Be $false

        Write-PwshSecretsFile -Pairs ([ordered]@{ LIMA = 'ten' }) -Path $out | Out-Null

        $acl = Get-Acl -LiteralPath $out
        $acl.AreAccessRulesProtected | Should Be $true

        $ids = @($acl.Access | ForEach-Object { $_.IdentityReference.Value })
        ($ids -contains 'BUILTIN\Users') | Should Be $false
        ($ids -contains 'Everyone')      | Should Be $false

        $me = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        @($ids | Where-Object { $_ -ne $me }).Count | Should Be 0
    }

    # Cùng bẫy $LASTEXITCODE mà Update-PwshSecrets đã có test riêng. icacls hỏng
    # (LOCALAPPDATA trỏ sang share, volume không mang ACL, identity không phân
    # giải được) làm hàm throw, nhưng nếu mã thoát khác 0 còn sót lại thì nó sống
    # qua cả tiến trình -- bẩn segment exit-status của prompt, và làm đỏ job CI về
    # sau vì `shell: powershell` tự `exit $LASTEXITCODE` dù Pester báo 0 fail.
    #
    # icacls được thay bằng một function ở global scope: lookup lệnh trần từ trong
    # module rơi về global session state, nên module gọi đúng vào bản giả này.
    It 'resets $LASTEXITCODE when icacls fails instead of leaking it to the caller' {
        $out = Join-Path $WorkDir 'acl-fail.ps1'
        $global:LASTEXITCODE = 0
        function global:icacls { $global:LASTEXITCODE = 5 }
        try {
            { Write-PwshSecretsFile -Pairs ([ordered]@{ MIKE = 'eleven' }) -Path $out } | Should Throw
        }
        finally {
            Remove-Item -LiteralPath 'function:global:icacls' -Force -ErrorAction SilentlyContinue
        }

        $LASTEXITCODE | Should Be 0
        Test-Path -LiteralPath $out | Should Be $false
        @(Get-ChildItem -LiteralPath $WorkDir -Filter '.tmp.*' -Force).Count | Should Be 0
    }
}

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

        # Stub age "thành công" nhưng giải mã ra nội dung không có assignment
        # nào (chỉ comment) -- mô phỏng .age hỏng/không đúng định dạng mà vẫn
        # giải mã được. Thoát mã 0 nên không có nguy cơ rò $LASTEXITCODE.
        $AgeEmpty = Join-Path $WorkDir 'age-empty.cmd'
        Set-Content -LiteralPath $AgeEmpty -Value @(
            '@echo off'
            'echo # chi la comment, khong co assignment nao o day'
        )

        # Stub age hỏng CÓ nói lý do trên stderr -- đúng hình dạng của age thật
        # ("no identity matched any of the recipients", passphrase prompt, ...).
        # Chuỗi dưới đây là bịa, không phải thông điệp thật của bất kỳ máy nào.
        $AgeNoisy = Join-Path $WorkDir 'age-noisy.cmd'
        Set-Content -LiteralPath $AgeNoisy -Value @(
            '@echo off'
            'echo age: STUB-DIAGNOSTIC-LINE 1>&2'
            'exit /b 1'
        )
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

    It 'returns null and does not throw when the age command itself cannot be found' {
        $out = Join-Path $WorkDir 'out-noagecmd.ps1'
        $missingAge = Join-Path $WorkDir 'no-such-age.exe'
        $n = Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out -AgeCommand $missingAge
        $n | Should BeNullOrEmpty
        Test-Path -LiteralPath $out | Should Be $false
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

    It 'resets $LASTEXITCODE after a failed decrypt instead of leaking it to the caller' {
        # $LASTEXITCODE la bien toan cuc cua ca tien trinh PowerShell, khong
        # phai cuc bo ham. GitHub Actions' `shell: powershell` tu them
        # `exit $LASTEXITCODE` sau khi script chay xong -- mot lan decrypt
        # hong ma ham nay xu ly dung (return $null, khong throw) van co the
        # lam ca job CI bao fail neu $LASTEXITCODE con sot lai khac 0.
        $global:LASTEXITCODE = 0
        $out = Join-Path $WorkDir 'out-exitcode.ps1'
        Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out -AgeCommand $AgeFail | Out-Null
        $LASTEXITCODE | Should Be 0
    }

    It 'returns null and does not overwrite an existing file when decryption succeeds but nothing parses as an assignment' {
        $out = Join-Path $WorkDir 'out-empty.ps1'

        # Chua co file dich: guard rong phai khong tao ra gi ca.
        $n = Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out -AgeCommand $AgeEmpty
        $n | Should BeNullOrEmpty
        Test-Path -LiteralPath $out | Should Be $false

        # Da co file dich tu truoc (populate that su): guard rong phai giu
        # nguyen noi dung cu, khong duoc ghi de bang file chi co header.
        Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out -AgeCommand $AgeOk | Out-Null
        $before = Get-Content -LiteralPath $out -Raw

        $n2 = Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out -AgeCommand $AgeEmpty
        $n2 | Should BeNullOrEmpty
        (Get-Content -LiteralPath $out -Raw) | Should Be $before
    }

    # Mã thoát một mình không phân biệt được khoá sai, khoá có passphrase và
    # ciphertext hỏng -- cả ba đều là "exit 1". Cửa sổ tự nâng quyền của apply.ps1
    # lại rất dễ bị bỏ qua, nên chẩn đoán của age phải hiện ra.
    It 'surfaces age''s own stderr on the failure branch' {
        $out = Join-Path $WorkDir 'out-noisy.ps1'
        $log = & {
            Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out `
                -AgeCommand $AgeNoisy | Out-Null
        } 6>&1
        (($log | ForEach-Object { [string]$_ }) -join "`n") | Should Match 'STUB-DIAGNOSTIC-LINE'
    }

    # Mặt kia của cùng quyết định: đường THÀNH CÔNG không được log gì ngoài số
    # lượng và đường dẫn. Nội dung giải mã không bao giờ ra console.
    It 'never puts a decrypted value on the console on the success path' {
        $out = Join-Path $WorkDir 'out-quiet.ps1'
        $log = & {
            Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out `
                -AgeCommand $AgeOk | Out-Null
        } 6>&1
        $joined = ($log | ForEach-Object { [string]$_ }) -join "`n"
        $joined | Should Match '2 secrets'
        $joined | Should Not Match 'TEST_ALPHA'
        $joined | Should Not Match 'TEST_BRAVO'
    }

    It 'never throws, whatever is missing' {
        { Update-PwshSecrets -RepoRoot 'C:\nope' -Identity 'C:\nope' `
            -OutFile (Join-Path $WorkDir 'x.ps1') -AgeCommand 'C:\nope.exe' } | Should Not Throw
    }
}

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
        ($pwshAt   -ge 0) | Should Be $true
        ($agenixAt -ge 0) | Should Be $true
        ($agenixAt -gt $pwshAt) | Should Be $true
    }

    It 'installs age via scoop' {
        $ScoopText | Should Match "(?m)^\s*'age'\s*$"
    }

    It 'leaves OutFile at its default, so nothing is written under the repo' {
        $ModuleText = Get-Content -Raw -LiteralPath $ModulePath
        $ModuleText | Should Not Match '-OutFile'
    }

    # Khẳng định "Apply không rỗng" là vacuous: xoá đúng dòng làm việc
    # (`Update-PwshSecrets -RepoRoot $Ctx.RepoRoot`) mà vẫn còn Import-Module thì
    # block vẫn khác rỗng và test vẫn xanh, trong khi secret âm thầm ngừng được
    # sinh ra. Nên ở đây chạy Apply thật.
    #
    # Apply chỉ nhận $Ctx, mọi thứ khác là mặc định đọc từ môi trường -- nên cách
    # duy nhất quan sát được nó có gọi thật hay không là trỏ $env:USERPROFILE,
    # $env:LOCALAPPDATA và PATH vào một sandbox tạm rồi xem file có ra không.
    It 'really decrypts when Apply runs -- not just a non-empty scriptblock' {
        $Sandbox   = Join-Path $env:TEMP ("agenix-apply-" + [Guid]::NewGuid().ToString('N'))
        $FakeHome  = Join-Path $Sandbox 'home'
        $FakeLocal = Join-Path $Sandbox 'local'
        $FakeRepo  = Join-Path $Sandbox 'repo'
        $BinDir    = Join-Path $Sandbox 'bin'

        New-Item -ItemType Directory -Path (Join-Path $FakeHome '.ssh') -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $FakeHome '.ssh\id_ed25519') -Value 'not-a-real-key'

        $AgeDir = Join-Path $FakeRepo 'home-manager\programs\zsh\age.d'
        New-Item -ItemType Directory -Path $AgeDir -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $AgeDir 'apikey.zsh.age') -Value 'not-real-ciphertext'

        New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $BinDir 'age.cmd') -Value @(
            '@echo off'
            'echo export TEST_APPLY_ALPHA="applied"'
        )

        $oldHome = $env:USERPROFILE
        $oldLocal = $env:LOCALAPPDATA
        $oldPath = $env:PATH
        try {
            $env:USERPROFILE  = $FakeHome
            $env:LOCALAPPDATA = $FakeLocal
            $env:PATH         = "$BinDir;$env:PATH"

            $ctx = @{
                RepoRoot   = $FakeRepo
                WindowsDir = (Join-Path $RepoRoot 'windows')
            }
            $mod = & $ModulePath
            & $mod.Apply $ctx | Out-Null

            $produced = Join-Path $FakeLocal 'pwsh-secrets\apikey.ps1'
            Test-Path -LiteralPath $produced | Should Be $true
            (Get-Content -LiteralPath $produced -Raw) | Should Match '\$env:TEST_APPLY_ALPHA = ''applied'''
        }
        finally {
            $env:USERPROFILE  = $oldHome
            $env:LOCALAPPDATA = $oldLocal
            $env:PATH         = $oldPath
            $global:LASTEXITCODE = 0
            if (Test-Path -LiteralPath $Sandbox) {
                Remove-Item -LiteralPath $Sandbox -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

Describe 'pwsh shell wiring for secrets' {
    BeforeAll {
        $RepoRoot    = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $PwshDir     = Join-Path $RepoRoot 'home-manager\dotfiles\windows\pwsh'
        $DropInPath  = Join-Path $PwshDir 'ps1.d\apikey.ps1'
        $ProfileText = Get-Content -Raw -LiteralPath (Join-Path $PwshDir 'Microsoft.PowerShell_profile.ps1')
        $FuncText    = Get-Content -Raw -LiteralPath (Join-Path $PwshDir 'ps1.d\functions.ps1')
    }

    # Chỉ grep chuỗi 'pwsh-secrets' là vacuous: nó có mặt cả trong comment lẫn
    # trong Join-Path, nên xoá đúng dòng `. $SecretsFile` mà test vẫn xanh. Nạp
    # thật vào một $env:LOCALAPPDATA giả rồi kiểm biến có được đặt hay không.
    It 'ships a drop-in that really dot-sources the generated file' {
        Test-Path -LiteralPath $DropInPath | Should Be $true

        $Sandbox = Join-Path $env:TEMP ("dropin-" + [Guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path (Join-Path $Sandbox 'pwsh-secrets') -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $Sandbox 'pwsh-secrets\apikey.ps1') `
            -Value '$env:TEST_DROPIN_ALPHA = ''loaded'''

        $old = $env:LOCALAPPDATA
        try {
            $env:LOCALAPPDATA = $Sandbox
            . $DropInPath
            $env:TEST_DROPIN_ALPHA | Should Be 'loaded'
        }
        finally {
            $env:LOCALAPPDATA = $old
            Remove-Item Env:\TEST_DROPIN_ALPHA -ErrorAction SilentlyContinue
            if (Test-Path -LiteralPath $Sandbox) {
                Remove-Item -LiteralPath $Sandbox -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    # Máy chưa chạy apply.ps1 lần nào không được vỡ shell.
    It 'stays quiet when the generated file does not exist yet' {
        $old = $env:LOCALAPPDATA
        try {
            $env:LOCALAPPDATA = Join-Path $env:TEMP ("dropin-missing-" + [Guid]::NewGuid().ToString('N'))
            { . $DropInPath } | Should Not Throw
        }
        finally {
            $env:LOCALAPPDATA = $old
        }
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
        # Guard hiện diện: nếu một trong hai mốc bị đổi tên/xoá, IndexOf trả -1
        # và phép so sánh -gt/-lt phía dưới có thể pass giả (vacuous) thay vì
        # fail vì lý do đúng. Cùng lớp lỗi đã bị review bắt ở Task 4
        # ("runs after dotfiles.pwsh" thiếu guard này).
        ($alwaysOn    -ge 0) | Should Be $true
        ($interactive -ge 0) | Should Be $true
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

    # Hai test trên chỉ đọc chữ: xoá `$n = Update-PwshSecrets -RepoRoot $repo` thì
    # `function Update-Secrets` và alias vẫn còn, test vẫn xanh, còn agenix-reload
    # thành no-op nạp lại file cũ. Nên ở đây chạy thật, đầu-tới-đuôi: dựng một
    # $env:USERPROFILE\.nix giả (có bản sao thật của Secrets.psm1 + Logging.psm1),
    # một `age` stub trên PATH, rồi gọi hàm và kiểm biến có vào session hay không.
    It 'Update-Secrets really regenerates and loads the file into the running session' {
        $Sandbox   = Join-Path $env:TEMP ("reload-" + [Guid]::NewGuid().ToString('N'))
        $FakeHome  = Join-Path $Sandbox 'home'
        $FakeLocal = Join-Path $Sandbox 'local'
        $FakeRepo  = Join-Path $FakeHome '.nix'      # Update-Secrets hardcode $USERPROFILE\.nix
        $BinDir    = Join-Path $Sandbox 'bin'

        New-Item -ItemType Directory -Path (Join-Path $FakeHome '.ssh') -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $FakeHome '.ssh\id_ed25519') -Value 'not-a-real-key'

        $FakeLib = Join-Path $FakeRepo 'windows\lib'
        New-Item -ItemType Directory -Path $FakeLib -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $RepoRoot 'windows\lib\Secrets.psm1') -Destination $FakeLib
        Copy-Item -LiteralPath (Join-Path $RepoRoot 'windows\lib\Logging.psm1') -Destination $FakeLib

        $AgeDir = Join-Path $FakeRepo 'home-manager\programs\zsh\age.d'
        New-Item -ItemType Directory -Path $AgeDir -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $AgeDir 'apikey.zsh.age') -Value 'not-real-ciphertext'

        New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $BinDir 'age.cmd') -Value @(
            '@echo off'
            'echo export TEST_RELOAD_ALPHA="reloaded"'
        )

        $oldHome  = $env:USERPROFILE
        $oldLocal = $env:LOCALAPPDATA
        $oldPath  = $env:PATH
        try {
            $env:USERPROFILE  = $FakeHome
            $env:LOCALAPPDATA = $FakeLocal
            $env:PATH         = "$BinDir;$env:PATH"

            . (Join-Path $PwshDir 'ps1.d\functions.ps1')

            Update-Secrets
            $env:TEST_RELOAD_ALPHA | Should Be 'reloaded'

            # Alias phải dẫn tới đúng hàm đó, không chỉ tồn tại.
            Remove-Item Env:\TEST_RELOAD_ALPHA -ErrorAction SilentlyContinue
            agenix-reload
            $env:TEST_RELOAD_ALPHA | Should Be 'reloaded'
        }
        finally {
            $env:USERPROFILE  = $oldHome
            $env:LOCALAPPDATA = $oldLocal
            $env:PATH         = $oldPath
            $global:LASTEXITCODE = 0
            Remove-Item Env:\TEST_RELOAD_ALPHA -ErrorAction SilentlyContinue
            if (Test-Path -LiteralPath $Sandbox) {
                Remove-Item -LiteralPath $Sandbox -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
