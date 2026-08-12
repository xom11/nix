Describe 'windows New-IdempotentSymlink' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        Import-Module (Join-Path $RepoRoot 'windows\lib\Logging.psm1') -Force
        Import-Module (Join-Path $RepoRoot 'windows\lib\Symlink.psm1') -Force
    }

    It 'reports failure and touches nothing when the source is missing' {
        $target = Join-Path $TestDrive 'no-source-target.txt'
        New-IdempotentSymlink -Source (Join-Path $TestDrive 'does-not-exist') -Target $target |
            Should Be $false
        (Test-Path $target) | Should Be $false
    }

    It 'moves a real file out of the way instead of deleting it' {
        $source = Join-Path $TestDrive 'real-source.txt'
        $target = Join-Path $TestDrive 'real-target.txt'
        Set-Content -LiteralPath $source -Value 'from the repo' -Encoding UTF8
        Set-Content -LiteralPath $target -Value 'precious user data' -Encoding UTF8

        New-IdempotentSymlink -Source $source -Target $target | Out-Null

        # The point of the test: the original content still exists somewhere. An earlier
        # version ran Remove-Item -Force -Recurse over whatever was in the way.
        (Test-Path "$target.bak") | Should Be $true
        (Get-Content "$target.bak" -Raw).Trim() | Should Be 'precious user data'
    }

    It 'moves a real directory aside rather than recursing over it' {
        $source = Join-Path $TestDrive 'dir-source'
        $target = Join-Path $TestDrive 'dir-target'
        New-Item -ItemType Directory -Path $source | Out-Null
        New-Item -ItemType Directory -Path $target | Out-Null
        Set-Content -LiteralPath (Join-Path $target 'keepme.txt') -Value 'do not lose me' -Encoding UTF8

        New-IdempotentSymlink -Source $source -Target $target | Out-Null

        (Test-Path (Join-Path "$target.bak" 'keepme.txt')) | Should Be $true
        (Get-Content (Join-Path "$target.bak" 'keepme.txt') -Raw).Trim() | Should Be 'do not lose me'
    }

    It 'does not collide when something has already been moved aside once' {
        $source = Join-Path $TestDrive 'collide-source.txt'
        $target = Join-Path $TestDrive 'collide-target.txt'
        Set-Content -LiteralPath $source -Value 'from the repo' -Encoding UTF8
        Set-Content -LiteralPath "$target.bak" -Value 'older backup' -Encoding UTF8
        Set-Content -LiteralPath $target -Value 'newer data' -Encoding UTF8

        New-IdempotentSymlink -Source $source -Target $target | Out-Null

        (Get-Content "$target.bak" -Raw).Trim()  | Should Be 'older backup'
        (Get-Content "$target.bak1" -Raw).Trim() | Should Be 'newer data'
    }
}

Describe 'windows New-IdempotentSymlink stops on a non-terminating New-Item error' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:LibText = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\lib\Symlink.psm1')
    }

    It 'passes -ErrorAction Stop on the New-Item call itself' {
        # The bug this pins, measured on a14 2026-08-12: New-Item reports
        # "Administrator privilege required for this operation" as a NON-terminating
        # error, so `catch` never fired -- New-IdempotentSymlink printed OK and
        # returned $true for a link that did not exist. Measured both ways on one
        # machine, same call, only this token differing:
        #     with    -ErrorAction Stop -> returned False, target absent
        #     without                   -> returned True,  target absent
        # A whole apply run on a machine without the privilege reports every link
        # green while linking nothing.
        #
        # apply.ps1 sets $ErrorActionPreference = 'Stop' and that looks like it
        # should cover this. It does not: preference variables do not cross a
        # module boundary, so code in a .psm1 runs under the module's own scope,
        # which defaults to Continue. Nothing the caller does substitutes for the
        # parameter, which is why this is asserted on the call and not on apply.ps1.
        #
        # WHY A TEXT GATE AND NOT A BEHAVIOURAL ONE. Three behavioural routes were
        # built and measured, and each fails in its own way:
        #   - Mock -ModuleName Symlink New-Item { Write-Error ... } -- PASSES WITH
        #     AND WITHOUT the fix. Pester 3's mock does not honour the -ErrorAction
        #     passed to it, so the test proved nothing; only mutating the source
        #     exposed that it was vacuous.
        #   - a target under a parent directory that does not exist -- discriminates
        #     on an unprivileged machine, but with admin rights New-Item -Force
        #     creates the missing parents and succeeds, so CI (privileged) would go
        #     red for the wrong reason.
        #   - the real permission failure -- only reproducible on a machine that
        #     lacks the privilege, i.e. never on CI.
        # So this asserts the one token whose removal is the regression.
        $line = [regex]::Match($script:LibText, '(?m)^\s*New-Item -ItemType SymbolicLink .*$').Value
        $line | Should Match 'New-Item -ItemType SymbolicLink'
        $line | Should Match '-ErrorAction Stop'
    }
}
