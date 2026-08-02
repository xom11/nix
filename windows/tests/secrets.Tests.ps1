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
}

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
}
