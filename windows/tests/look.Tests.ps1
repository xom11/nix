Describe 'windows/modules/programs/look' {
    BeforeAll {
        $RepoRoot  = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ModPath   = Join-Path $RepoRoot 'windows\modules\programs\look\module.ps1'
        $ApplyPath = Join-Path $RepoRoot 'windows\apply.ps1'
        $ModText   = if (Test-Path $ModPath) { Get-Content -LiteralPath $ModPath -Raw } else { '' }
        $ApplyText = Get-Content -LiteralPath $ApplyPath -Raw

        # The single line that actually runs the downloaded .exe.
        $StartLine = ($ModText -split "`r?`n" | Where-Object { $_ -match 'Start-Process' }) -join "`n"
    }

    It 'ships a module file' {
        Test-Path $ModPath | Should Be $true
    }

    It 'is registered in apply.ps1' {
        $ApplyText | Should Match "(?m)^\s*'programs\.look'"
    }

    It 'returns a hashtable with Description and Apply' {
        $mod = & $ModPath
        $mod.Description | Should Not BeNullOrEmpty
        $mod.Apply | Should Not BeNullOrEmpty
    }

    It 'resolves the release from the GitHub API' {
        # look ships no winget manifest and no scoop bucket, so there is no
        # package manager to delegate this to -- the release feed is the only
        # Windows channel that exists.
        $ModText | Should Match 'releases/latest'
    }

    It 'refuses to install when the release has no checksums file' {
        # Tracking latest removes the review step that a version pin gave, so
        # the hash check is the only thing standing between an elevated
        # installer run and whatever upstream published minutes ago. A release
        # without checksums has to stop, not fall through to an unverified
        # install.
        $ModText | Should Match 'publishes no windows-checksums'
    }

    It 'verifies SHA256 before running the installer' {
        # Ordering, not mere presence: a hash check that happens after the
        # installer has already run verifies nothing. Both strings occur once
        # each in this file, so IndexOf is unambiguous.
        $hashAt  = $ModText.IndexOf('Get-FileHash')
        $startAt = $ModText.IndexOf('Start-Process')
        $hashAt | Should Not Be -1
        $startAt | Should Not Be -1
        ($hashAt -lt $startAt) | Should Be $true
    }

    It 'survives an unreachable release feed' {
        # Offline or rate-limited must not fail the whole apply run when look is
        # already installed -- same contract as packages/pwsh, which downloads
        # from a GitHub release the same way.
        $ModText | Should Match 'release check failed'
    }

    It 'passes /D= as the last installer argument, unquoted' {
        # NSIS requires /D= to be final and bare -- quoting it, or appending
        # anything after it, silently installs to the default location instead
        # of $installDir. The closing paren immediately after is what proves it
        # is still last.
        $StartLine | Should Match '"/D=\$installDir"\)'
    }

    It 'does not launch the app from apply' {
        # Over SSH apply.ps1 runs in session 0, which has no desktop. A GUI
        # started there is an invisible process holding the Alt+Space hotkey.
        $ModText | Should Not Match 'Start-Process[^\r\n]*\$exe'
    }

    It 'installs on ARM64 instead of skipping' {
        # Upstream publishes x86_64 only; on a14 the launcher runs under Prism
        # emulation. That is a deliberate choice, so ARM64 must warn and carry
        # on -- turning it into a skip would quietly uninstall the feature from
        # the only Windows host this repo has.
        $ModText | Should Match "'ARM64'\s*\{\s*Write-Warn"
    }
}
