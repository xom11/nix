Describe 'windows/modules/programs/look' {
    BeforeAll {
        $RepoRoot  = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ModPath   = Join-Path $RepoRoot 'windows\modules\programs\look\module.ps1'
        $ApplyPath = Join-Path $RepoRoot 'windows\apply.ps1'
        $ModText   = if (Test-Path $ModPath) { Get-Content -LiteralPath $ModPath -Raw } else { '' }
        $ApplyText = Get-Content -LiteralPath $ApplyPath -Raw

        # Anchor on the assignment, not on the string wherever it appears. The
        # comment above the pin names the release page, and the next person to
        # touch it may well paste a version number into that prose -- at which
        # point a whole-file match would keep passing even after the real
        # assignment had drifted to something unpinned.
        $VersionLine = ($ModText -split "`r?`n" | Where-Object { $_ -match '^\s*\$Version\s*=' }) -join "`n"

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

    It 'pins an exact release version' {
        # This module downloads an .exe from GitHub and executes it, from a
        # script already running as Administrator. Unpinned, every future
        # upstream release would reach that position unreviewed, with nothing
        # recording which build landed. The exact-version match is the whole
        # point of the assertion: 'points at a GitHub release' would pass just
        # as happily on a source that tracks whatever is newest.
        # Single-quoted: in a double-quoted string PowerShell expands `$Version`
        # to the empty string before Pester ever sees the pattern, and the
        # assertion then matches almost anything.
        $VersionLine | Should Match '^\s*\$Version\s*=\s*''\d+\.\d+\.\d+''\s*$'
    }

    It 'never resolves the latest release at runtime' {
        # The companion to the pin. Keeping the assignment while adding a
        # `releases/latest` lookup elsewhere would defeat it silently.
        $ModText | Should Not Match 'releases/latest'
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
