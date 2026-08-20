# `Import-Module Logging.psm1 -Force` from inside Secrets.psm1 runs Remove-Module
# first, killing apply.ps1's global binding while the re-import lands in Secrets'
# own session state. The next `Write-Section` then throws past the inner try, and
# apply.ps1 exits 1 with 8 modules unrun -- including services.sshd, which is what
# keeps SSH into that machine.
#
# First in the file on purpose: later Describes re-import Logging and would
# accidentally patch the breakage away.
Describe 'windows/lib/Secrets.psm1 import hygiene' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    }

    It 'leaves the caller''s Logging bindings alive after Secrets.psm1 is imported' {
        Import-Module (Join-Path $RepoRoot 'windows\lib\Logging.psm1') -Force -DisableNameChecking
        (Get-Command Write-Section -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty

        Import-Module (Join-Path $RepoRoot 'windows\lib\Secrets.psm1') -Force
        (Get-Command Write-Section -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty

        # Second import: apply.ps1 + Update-Secrets in one process.
        Import-Module (Join-Path $RepoRoot 'windows\lib\Secrets.psm1') -Force
        (Get-Command Write-Section -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        (Get-Command Write-Fail    -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
    }

    # The other half: dropping the Import-Module line is equally wrong, since
    # Update-Secrets imports Secrets.psm1 into a session with no Logging. Run in a
    # child process so this session's Logging cannot mask it.
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
        # Not an endorsement -- just proof the parser does not interpolate.
        $text = 'export FOXTROT="a$b`c"'
        $got = ConvertFrom-ShellEnv -Text $text
        $got['FOXTROT'] | Should Be 'a$b`c'
    }

    # Records a known LIMITATION, not correct behaviour. The parser strips one
    # outer quote pair and treats the rest as data, while zsh concatenates
    # adjacent quoted words. CLAUDE.md forbids `'` and `"` inside a value, so no
    # valid value reaches this branch. Fix the parser before relaxing that rule --
    # do not lean on this test to say it is fine.
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
        ($ids -contains 'BUILTIN\Users')             | Should Be $false
        ($ids -contains 'Everyone')                  | Should Be $false
        ($ids -contains 'NT AUTHORITY\Authenticated Users') | Should Be $false

        # No hardcoded account name: the Actions runner differs from the real
        # machine. SYSTEM and Administrators are allowed -- both can take
        # ownership regardless of the DACL. Joined rather than counted so a
        # failure names the offending principal.
        $me = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $allowed = @($me, 'NT AUTHORITY\SYSTEM', 'BUILTIN\Administrators')
        (@($ids | Where-Object { $allowed -notcontains $_ }) -join ', ') | Should Be ''
    }

    # The overwrite path goes through ReplaceFileW, which carries the REPLACED
    # file's DACL onto the replacement, discarding the ACL set on the temp. So a
    # target that once had inherited permissions keeps them through every later
    # apply, while still reporting success.
    It 'reapplies the restrictive ACL on the overwrite path, not just on first write' {
        $out = Join-Path $WorkDir 'acl-overwrite.ps1'

        # Hand-created, so it inherits the parent's ACL -- the test's premise.
        Set-Content -LiteralPath $out -Value '# placeholder'
        (Get-Acl -LiteralPath $out).AreAccessRulesProtected | Should Be $false

        Write-PwshSecretsFile -Pairs ([ordered]@{ LIMA = 'ten' }) -Path $out | Out-Null

        $acl = Get-Acl -LiteralPath $out
        $acl.AreAccessRulesProtected | Should Be $true

        $ids = @($acl.Access | ForEach-Object { $_.IdentityReference.Value })
        ($ids -contains 'BUILTIN\Users')             | Should Be $false
        ($ids -contains 'Everyone')                  | Should Be $false
        ($ids -contains 'NT AUTHORITY\Authenticated Users') | Should Be $false

        $me = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $allowed = @($me, 'NT AUTHORITY\SYSTEM', 'BUILTIN\Administrators')
        (@($ids | Where-Object { $allowed -notcontains $_ }) -join ', ') | Should Be ''
    }

    # $LASTEXITCODE is process-global, and `shell: powershell` appends
    # `exit $LASTEXITCODE`, so a leaked non-zero code reddens a CI job even when
    # Pester reports 0 failures. icacls is stubbed at global scope because a bare
    # command lookup from inside a module falls back to global session state.
    It 'resets $LASTEXITCODE when icacls fails instead of leaking it to the caller' {
        $out = Join-Path $WorkDir 'acl-fail.ps1'
        $global:LASTEXITCODE = 0
        function global:icacls { $global:LASTEXITCODE = 5 }
        try {
            { Write-PwshSecretsFile -Pairs ([ordered]@{ MIKE = 'eleven' }) -Path $out } | Should Throw
        }
        finally {
            # `Function:\icacls`, NOT `function:global:icacls`: `global:` is a
            # scope modifier, not a provider path segment, so the latter deletes
            # nothing and the stub survives into every later test.
            if (Test-Path 'Function:\icacls') { Remove-Item 'Function:\icacls' -Force }
        }

        # Prove the cleanup rather than trusting it.
        (Get-Command icacls).CommandType | Should Be 'Application'

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

        # Fake repo: only the path to the .age file matters, since `age` is a stub.
        $FakeRepo = Join-Path $WorkDir 'repo'
        $AgeDir   = Join-Path $FakeRepo 'home-manager\programs\zsh\age.d'
        New-Item -ItemType Directory -Path $AgeDir -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $AgeDir 'apikey.zsh.age') -Value 'not-real-ciphertext'

        $FakeKey = Join-Path $WorkDir 'id_ed25519'
        Set-Content -LiteralPath $FakeKey -Value 'not-a-real-key'

        # age stub, success: prints two made-up lines.
        $AgeOk = Join-Path $WorkDir 'age-ok.cmd'
        Set-Content -LiteralPath $AgeOk -Value @(
            '@echo off'
            'echo export TEST_ALPHA="one"'
            'echo export TEST_BRAVO="two"'
        )

        # age stub, failure: non-zero exit, no output.
        $AgeFail = Join-Path $WorkDir 'age-fail.cmd'
        Set-Content -LiteralPath $AgeFail -Value @('@echo off', 'exit /b 1')

        # age stub that succeeds but decrypts to no assignments -- a malformed
        # .age that still decrypts. Exits 0, so no $LASTEXITCODE leak.
        $AgeEmpty = Join-Path $WorkDir 'age-empty.cmd'
        Set-Content -LiteralPath $AgeEmpty -Value @(
            '@echo off'
            'echo # chi la comment, khong co assignment nao o day'
        )

        # age stub that fails WITH a reason on stderr, the shape real age has.
        # The string below is invented, not a real message from any machine.
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
        # A decrypt this function handles correctly (returns $null, no throw)
        # can still redden CI if it leaks a non-zero $LASTEXITCODE.
        $global:LASTEXITCODE = 0
        $out = Join-Path $WorkDir 'out-exitcode.ps1'
        Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out -AgeCommand $AgeFail | Out-Null
        $LASTEXITCODE | Should Be 0
    }

    It 'returns null and does not overwrite an existing file when decryption succeeds but nothing parses as an assignment' {
        $out = Join-Path $WorkDir 'out-empty.ps1'

        # No target yet: the empty guard must create nothing.
        $n = Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out -AgeCommand $AgeEmpty
        $n | Should BeNullOrEmpty
        Test-Path -LiteralPath $out | Should Be $false

        # Target already populated: the empty guard must leave it untouched.
        Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out -AgeCommand $AgeOk | Out-Null
        $before = Get-Content -LiteralPath $out -Raw

        $n2 = Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out -AgeCommand $AgeEmpty
        $n2 | Should BeNullOrEmpty
        (Get-Content -LiteralPath $out -Raw) | Should Be $before
    }

    # Exit code alone cannot tell a wrong key from a passphrase-protected one
    # from broken ciphertext -- all three are "exit 1".
    It 'surfaces age''s own stderr on the failure branch' {
        $out = Join-Path $WorkDir 'out-noisy.ps1'
        $log = & {
            Update-PwshSecrets -RepoRoot $FakeRepo -Identity $FakeKey -OutFile $out `
                -AgeCommand $AgeNoisy | Out-Null
        } 6>&1
        (($log | ForEach-Object { [string]$_ }) -join "`n") | Should Match 'STUB-DIAGNOSTIC-LINE'
    }

    # The other side: the success path logs only a count and a path, never a
    # decrypted value.
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
        # The scoop list moved into pkg.toml when dotpkg took over installing
        # (2026-08-12); windows\modules\packages\scoop\module.ps1 no longer exists.
        $ScoopText  = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'home-manager\dotfiles\windows\dotpkg\pkg.toml')
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

    It 'runs after packages.dotpkg, which provides age' {
        # Was packages.scoop until 2026-08-12; dotpkg installs both backends now,
        # so the module that has to come first is packages.dotpkg.
        $pkgAt    = $ApplyText.IndexOf("'packages.dotpkg'")
        $agenixAt = $ApplyText.IndexOf("'programs.agenix'")
        ($pkgAt    -ge 0) | Should Be $true
        ($agenixAt -ge 0) | Should Be $true
        ($agenixAt -gt $pkgAt) | Should Be $true
    }

    It 'runs after dotfiles.pwsh, which links ps1.d' {
        $pwshAt   = $ApplyText.IndexOf("'dotfiles.pwsh'")
        $agenixAt = $ApplyText.IndexOf("'programs.agenix'")
        ($pwshAt   -ge 0) | Should Be $true
        ($agenixAt -ge 0) | Should Be $true
        ($agenixAt -gt $pwshAt) | Should Be $true
    }

    It 'installs age via scoop' {
        # TOML double-quotes package names and packs several onto a line, so this
        # cannot be line-anchored the way the old single-quoted module list was.
        $ScoopText | Should Match '"age"'
    }

    It 'leaves OutFile at its default, so nothing is written under the repo' {
        $ModuleText = Get-Content -Raw -LiteralPath $ModulePath
        $ModuleText | Should Not Match '-OutFile'
    }

    # Asserting "Apply is non-empty" is vacuous: delete the line that does the
    # work and the block is still non-empty while secrets silently stop being
    # generated. So run Apply for real, with USERPROFILE/LOCALAPPDATA/PATH
    # pointed at a sandbox -- that is the only observable.
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

    # Grepping for 'pwsh-secrets' is vacuous -- it appears in a comment and in
    # Join-Path, so deleting `. $SecretsFile` still passes. Load it for real.
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

    # A machine that has never run apply.ps1 must not break the shell.
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
        # Deliberately simple: the next test checks which block it lands in. A
        # regex spanning the `foreach` line would break the first time the list
        # is wrapped.
        $ProfileText | Should Match "'apikey\.ps1'"
    }

    It 'loads in the always-on block so pwsh -c over SSH gets the keys too' {
        $alwaysOn    = $ProfileText.IndexOf('always on: plain definitions')
        $interactive = $ProfileText.IndexOf('if (-not $Interactive) { return }')
        $apikeyAt    = $ProfileText.IndexOf("'apikey.ps1'")
        # Presence guards: a renamed marker makes IndexOf return -1, and the
        # -gt/-lt comparisons below would pass vacuously instead of failing.
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

    # The two tests above only read text: delete the line that regenerates and
    # both still pass while agenix-reload becomes a no-op reloading a stale file.
    # So run it end to end against a fake ~/.nix and an `age` stub on PATH.
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

            # The alias must reach that function, not merely exist.
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
