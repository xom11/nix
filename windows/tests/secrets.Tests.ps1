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
