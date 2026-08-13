Describe 'windows/modules/packages/dotpkg module contract' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:ModulePath = Join-Path $RepoRoot 'windows\modules\packages\dotpkg\module.ps1'
        $script:ModuleText = if (Test-Path -LiteralPath $script:ModulePath) {
            Get-Content -Raw -LiteralPath $script:ModulePath
        } else { '' }

        # Pull one `if`/`elseif` branch out of the module and return only its
        # CODE -- every `#` comment line removed. This module is heavily
        # commented on purpose, and prose that names the thing an assertion
        # forbids ("make this throw", "No --allow-prune") reads to a regex
        # exactly like the code doing it. Three assertions in this file have
        # already been wrong that way, two of them silently green.
        function Get-BranchCode {
            param([string]$Text, [string]$Pattern)
            $m = [regex]::Match($Text, $Pattern)
            if (-not $m.Success) { return '' }
            ($m.Value -split "`n" | Where-Object { $_ -notmatch '^\s*#' }) -join "`n"
        }
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

        # And they point at the repo, not at %USERPROFILE%. The home-directory
        # links were removed on 2026-08-12: dotpkg rewrites the lock with
        # File::create + fs::rename, and a rename turns a symlink into a real
        # file, after which the repo silently stops receiving pins.
        $script:ModuleText | Should Match '\$Ctx\.RepoRoot'
        $script:ModuleText | Should Not Match '\$config = Join-Path \$env:USERPROFILE'
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

    It 'takes ErrorActionPreference off Stop around the native call' {
        # Without this the module cannot work at all. apply.ps1 sets
        # $ErrorActionPreference = 'Stop', and this Apply block runs under the
        # CALLER's preference because it is a scriptblock invoked with `&`. Under
        # 'Stop', PowerShell 5.1 turns anything a native command writes to stderr
        # into a terminating NativeCommandError -- and dotpkg writes its warnings
        # there.
        #
        # Measured on a14 2026-08-12: the module threw on the first warning line
        # (`winget list` collapsing duplicate rows), which is not an error and
        # cannot be silenced. The exit code was never reached. Every real
        # apply.ps1 run would have failed this module.
        $script:ModuleText | Should Match "\`$ErrorActionPreference = 'Continue'"
        $script:ModuleText | Should Match 'finally'

        # The call has to sit INSIDE that window, not before or after it.
        #
        # Anchored on the call and searched outwards, because there is now MORE
        # THAN ONE such window: the version gate relaxes and restores around
        # `dotpkg --version` before this one. Taking the first match of each
        # made the assertion compare the apply call against the version gate's
        # `finally` and fail on a module that was correct.
        $callAt = [regex]::Match($script:ModuleText, '(?m)^\s*dotpkg apply ')
        $callAt.Success | Should Be $true

        # Nearest relax BEFORE the call, nearest restore AFTER it.
        $relaxBefore = @(
            [regex]::Matches($script:ModuleText, "(?m)^\s*\`$ErrorActionPreference = 'Continue'") |
                Where-Object { $_.Index -lt $callAt.Index }
        )
        $restoreAfter = @(
            [regex]::Matches($script:ModuleText, '(?m)^\s*\} finally \{') |
                Where-Object { $_.Index -gt $callAt.Index }
        )

        $relaxBefore.Count  | Should BeGreaterThan 0
        $restoreAfter.Count | Should BeGreaterThan 0
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

    It 'fails the run on exit 1, now that exit 3 carries the benign case' {
        # This assertion is the inverse of what it said until 2026-08-13, and the
        # flip is the whole point of requiring dotpkg >= 0.2.0.
        #
        # Before: 1 meant "something is outstanding", and dotpkg said outright
        # that one of the things it covered -- a package skipped because its own
        # process was running -- "is not a failure". On this fleet that is the
        # NORMAL state (python, beckon and kanata run essentially always), so
        # throwing on 1 would have painted apply.ps1 red every run and the module
        # only warned -- which meant a real failure warned too.
        #
        # After: 0.2.0 added exit 3 for exactly that benign case, so 1 means only
        # "failed, could not be prepared, or held". A warning is too weak for it.
        $one = Get-BranchCode -Text $script:ModuleText -Pattern '(?ms)\$rc -eq 1.*?\r?\n        \}'
        $one | Should Match 'throw'
        $one | Should Not Match 'Write-Warn'

        # And the else branch -- everything not named above -- must still throw.
        $script:ModuleText | Should Match '(?ms)\} else \{.*?throw'
    }

    It 'refuses to run against a dotpkg too old to read pkg.toml' {
        # pkg.toml declares `[winget.opts] pin = "none"`, and 0.1.0 does not
        # ignore that table -- it refuses the whole file with `unknown field
        # 'opts', expected 'packages' or 'guard'`, so every package silently goes
        # unmanaged. Measured on a14 2026-08-12.
        #
        # The gate is only expressible because 0.2.0 bumped the version: builds
        # from main used to report 0.1.0 as well, so no consumer could tell a
        # fixed binary from the released one.
        $script:ModuleText | Should Match "\[version\]'0\.2\.0'"
        $script:ModuleText | Should Match 'dotpkg --version'

        # The comparison has to be a version comparison, not a string one:
        # '0.10.0' -lt '0.2.0' is true for strings and false for versions.
        $script:ModuleText | Should Match '\[version\]\$Matches\[1\]'
    }

    It 'treats exit 3 as success' {
        # Added upstream because of this integration: 3 means "everything dotpkg
        # could do succeeded, and the only thing left is a package skipped
        # because its own process was running -- there is nothing to diagnose".
        #
        # Nothing on this fleet emits it yet: v0.1.0 is the only release and it
        # predates the change. Asserted anyway so the arm cannot be dropped by
        # someone tidying up a branch that "never runs", which is exactly what it
        # looks like today.
        $three = Get-BranchCode -Text $script:ModuleText -Pattern '(?ms)\$rc -eq 3.*?\r?\n        \}'
        $three | Should Match 'Write-OK'
        $three | Should Not Match 'throw'
    }

    It 'names the SSH limitation in a comment' {
        # Over SSH the sshd service's Redirection Guard blocks traversal of scoop
        # junctions created by a non-elevated user, so those packages come back as
        # unreadable and are SKIPPED rather than acted on. Measured on a14
        # 2026-08-12. Silent degradation is exactly what a comment has to catch.
        $script:ModuleText | Should Match 'Redirection Guard'
    }
}
