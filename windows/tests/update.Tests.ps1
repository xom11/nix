Describe 'update: the Windows half of the shared `update` command' {
    BeforeAll {
        $RepoRoot    = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $PwshDir     = Join-Path $RepoRoot 'home-manager\dotfiles\windows\pwsh'
        $AliasText   = Get-Content -LiteralPath (Join-Path $PwshDir 'ps1.d\alias.ps1') -Raw
        $ProfileText = Get-Content -LiteralPath (Join-Path $PwshDir 'Microsoft.PowerShell_profile.ps1') -Raw
        $LinksText   = Get-Content -LiteralPath (Join-Path $RepoRoot 'windows\links.ps1') -Raw
    }

    It 'defines an update function' {
        # (?m) so ^ anchors per line -- PowerShell's -match is single-line by default.
        $AliasText | Should Match '(?m)^function update\b'
    }

    It 'pulls the repo first and refuses to merge a diverged history' {
        $AliasText | Should Match 'git -C \$repo pull --ff-only'
    }

    It 'runs the shared apply.ps1 without re-elevating or pausing' {
        # Single-quoted: PowerShell's double quotes do not treat \ as an escape (the escape
        # character is the backtick), so "\\\\" would reach the regex engine as four
        # backslashes and match nothing here.
        $AliasText | Should Match 'windows\\apply\.ps1'
        $AliasText | Should Match '-NoElevate -NoWait'
    }

    It 'leaves package upgrades out of the command' {
        # apply.ps1 installs what is missing and skips the rest; upgrading scoop/winget
        # packages is a separate, manual decision and must not creep in here.
        #
        # Read the function body with comments stripped, not the whole file: the comment
        # above `update` names both commands to say why they are absent, and asserting over
        # the raw text fails on the very sentence documenting the rule.
        $body = [regex]::Match($AliasText, '(?ms)^function update \{.*?^\}').Value
        $body | Should Not BeNullOrEmpty
        $code = ($body -split "`n" | Where-Object { $_ -notmatch '^\s*#' }) -join "`n"
        $code | Should Not Match 'scoop\s+update'
        $code | Should Not Match 'winget\s+upgrade'
    }

    It 'is defined before the profile returns early for non-interactive shells' {
        # `ssh a14-win update` arrives through `pwsh -c`, which the profile classifies as
        # non-interactive. alias.ps1 has to be dot-sourced above that return, or the command
        # exists only in a human's terminal and every remote invocation fails.
        #
        # Matches on 'alias.ps1' alone, not the exact neighbor list: the always-on foreach
        # gained 'apikey.ps1' ahead of it (windows secrets wiring), and pinning to
        # "'env.ps1', 'alias.ps1'" would break every time the list order changes without the
        # thing this test actually cares about -- alias.ps1 vs. the early return -- moving.
        $dotSource = $ProfileText.IndexOf("'alias.ps1'")
        $earlyExit = $ProfileText.IndexOf('if (-not $Interactive) { return }')
        ($dotSource -ge 0 -and $earlyExit -ge 0 -and $dotSource -lt $earlyExit) | Should Be $true
    }

    It 'reaches the machine through the pwsh symlink rather than a copy' {
        $LinksText | Should Match 'ps1\.d'
    }
}
