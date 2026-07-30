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
        $AliasText | Should Match "windows\\\\apply\.ps1"
        $AliasText | Should Match '-NoElevate -NoWait'
    }

    It 'leaves package upgrades out of the command' {
        # apply.ps1 installs what is missing and skips the rest; upgrading scoop/winget
        # packages is a separate, manual decision and must not creep in here.
        $AliasText | Should Not Match 'scoop\s+update'
        $AliasText | Should Not Match 'winget\s+upgrade'
    }

    It 'is defined before the profile returns early for non-interactive shells' {
        # `ssh a14-win update` arrives through `pwsh -c`, which the profile classifies as
        # non-interactive. alias.ps1 has to be dot-sourced above that return, or the command
        # exists only in a human's terminal and every remote invocation fails.
        $dotSource = $ProfileText.IndexOf("'env.ps1', 'alias.ps1'")
        $earlyExit = $ProfileText.IndexOf('if (-not $Interactive) { return }')
        ($dotSource -ge 0 -and $earlyExit -ge 0 -and $dotSource -lt $earlyExit) | Should Be $true
    }

    It 'reaches the machine through the pwsh symlink rather than a copy' {
        $LinksText | Should Match 'ps1\.d'
    }
}
