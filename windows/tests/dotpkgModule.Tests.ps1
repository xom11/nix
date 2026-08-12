Describe 'windows/modules/packages/dotpkg module contract' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:ModulePath = Join-Path $RepoRoot 'windows\modules\packages\dotpkg\module.ps1'
        $script:ModuleText = if (Test-Path -LiteralPath $script:ModulePath) {
            Get-Content -Raw -LiteralPath $script:ModulePath
        } else { '' }
    }

    It 'exists and is a module hashtable with an Apply block' {
        (Test-Path -LiteralPath $script:ModulePath) | Should Be $true
        $script:ModuleText | Should Match 'Description\s*='
        $script:ModuleText | Should Match 'Apply\s*='
    }

    It 'bootstraps scoop before calling dotpkg' {
        # dotpkg states outright that on a machine with neither manager it has
        # nothing to do -- it MANAGES scoop, it does not install it. A fresh
        # machine therefore needs this call, and needs it first.
        #
        # Both indexes come from a CALL-SHAPED match, not a bare substring. The
        # first version used $ModuleText.IndexOf('Install-Scoop'), and a mutation
        # run proved it worthless: the module has a comment mentioning
        # `Install-ScoopPackages` ABOVE the invocation, so IndexOf found the
        # comment and the ordering assertion passed with the bootstrap moved to
        # the very end of the Apply block.
        $installMatch = [regex]::Match($script:ModuleText, '(?m)^\s*if \(-not \(Install-Scoop\)\)')
        $applyMatch   = [regex]::Match($script:ModuleText, '(?m)^\s*dotpkg apply ')

        $installMatch.Success | Should Be $true
        $applyMatch.Success   | Should Be $true
        $installMatch.Index   | Should BeLessThan $applyMatch.Index
    }

    It 'refuses to install the dotpkg binary itself' {
        # This repo pins no dotpkg version anywhere -- not in flake.lock, not in a
        # scoop manifest, nowhere. A module that downloaded the binary would be
        # inventing a second pin channel that nothing declares and nothing tests.
        # Fail with instructions instead.
        $script:ModuleText | Should Not Match 'Invoke-WebRequest'
        $script:ModuleText | Should Not Match 'Invoke-RestMethod'
        $script:ModuleText | Should Match 'releases'
    }

    # Every flag assertion below reads the INVOCATION LINE, not the whole file.
    # Matching the file cannot tell code from prose: the first version of the
    # prune assertion failed against a comment that said "No --allow-prune,
    # deliberately", and it would equally have PASSED a module that only
    # mentioned --keep-going in a comment and never passed it. The line is the
    # thing that runs, so the line is the thing to assert on.
    It 'passes config and lock explicitly rather than trusting the working directory' {
        # dotpkg defaults to ./pkg.toml and apply.ps1 guarantees no working
        # directory. Measured 2026-08-12: a scheduled task whose CWD was system32
        # made dotpkg report "cannot read pkg.toml" and nothing else.
        $line = [regex]::Match($script:ModuleText, '(?m)^\s*dotpkg apply .*$').Value
        $line | Should Match '--config'
        $line | Should Match '--lock'
    }

    It 'never prunes' {
        # apply.ps1 has never uninstalled anything, and keeping that property also
        # keeps the run clear of dotpkg's refusal to remove a user-scope winget
        # package from an elevated process -- and apply.ps1 always self-elevates.
        $line = [regex]::Match($script:ModuleText, '(?m)^\s*dotpkg apply .*$').Value
        $line | Should Not Match '--allow-prune'
    }

    It 'passes the three flags a fresh machine needs' {
        $line = [regex]::Match($script:ModuleText, '(?m)^\s*dotpkg apply .*$').Value

        # A gate that matched nothing would pass every assertion below.
        $line | Should Match 'dotpkg apply'

        $line | Should Match '--yes'
        $line | Should Match '--keep-going'
        $line | Should Match '--clone-missing-buckets'
    }

    It 'clears LASTEXITCODE after the external call' {
        # A leaked non-zero $LASTEXITCODE turns a green Pester run into a red
        # GitHub Actions job, with nothing in the test output to explain it.
        $script:ModuleText | Should Match '\$global:LASTEXITCODE\s*=\s*0'
    }

    It 'throws rather than only printing, so a failure is counted as one' {
        # apply.ps1 wraps `& $mod.Apply $Ctx` in try/catch and counts a module as
        # FAILED only when it throws. Write-Fail prints and still counts as ok.
        # For a module that installs packages, silently-counted-as-green is the
        # worst failure mode available.
        $script:ModuleText | Should Match 'throw'
    }

    It 'names the SSH limitation in a comment' {
        # Over SSH the sshd service's Redirection Guard blocks traversal of scoop
        # junctions created by a non-elevated user, so those packages come back as
        # unreadable and are SKIPPED rather than acted on. Measured on a14
        # 2026-08-12. Silent degradation is exactly what a comment has to catch.
        $script:ModuleText | Should Match 'Redirection Guard'
    }
}
