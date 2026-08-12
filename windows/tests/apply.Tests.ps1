Describe 'windows/apply.ps1 shared entry point' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ApplyText = Get-Content -LiteralPath (Join-Path $RepoRoot 'windows\apply.ps1') -Raw
        $ObsoleteHostFile = Join-Path $RepoRoot 'hosts\zenbook-a14\windows.ps1'
        $ExpectedModules = @(
            'dotfiles.dotpkg'
            'packages.dotpkg'
            'packages.pwsh'
            'packages.psmodules'
            'packages.npm'
            'dotfiles.pwsh'
            'dotfiles.windows-terminal'
            'dotfiles.ai.claude'
            'dotfiles.ai.codex'
            'dotfiles.ai.gemini'
            'dotfiles.ai.aichat'
            'dotfiles.ai.opencode'
            'dotfiles.ai.pi'
            'programs.ssh'
            'programs.nvim'
            'programs.yazi'
            'programs.beckon'
            'services.kanata'
            'services.kanata-watchdog'
            'services.ahk'
            'services.ahk-watchdog'
            'services.beckon-serve'
            'services.beckon-serve-watchdog'
            'services.sshd'
        )
        # Kept in the file as commented-out entries so the reason survives; they must not be
        # silently active. The plain-substring assertion below cannot tell the two apart, so
        # these get their own check.
        $DisabledModules = @(
            'dotfiles.powertoys'
        )
    }

    It 'owns the single Windows module selection directly' {
        foreach ($module in $ExpectedModules) {
            # (?m) so ^ anchors per line -- PowerShell's -match is single-line by default.
            $ApplyText | Should Match ("(?m)^\s*'" + [regex]::Escape($module) + "'")
        }
    }

    It 'links pkg.toml before the module that reads it' {
        # packages.dotpkg reads %USERPROFILE%\pkg.toml and pkg.lock; dotfiles.dotpkg
        # is what puts them there. This constraint is new -- dotfiles.dotpkg used to
        # sit in the dotfiles group, which runs AFTER packages, and nothing noticed
        # because no packages module read those files. Reversed, a fresh machine
        # fails the packages module on a missing file and the cause is a list order
        # nobody looks at.
        #
        # Both indexes come from a quoted, line-anchored match so a mention in a
        # comment cannot satisfy either one.
        $linkAt = [regex]::Match($ApplyText, "(?m)^\s*'dotfiles\.dotpkg'")
        $useAt  = [regex]::Match($ApplyText, "(?m)^\s*'packages\.dotpkg'")

        $linkAt.Success | Should Be $true
        $useAt.Success  | Should Be $true
        $linkAt.Index   | Should BeLessThan $useAt.Index
    }

    It 'keeps disabled modules commented out rather than active' {
        foreach ($module in $DisabledModules) {
            $ApplyText | Should Match ("(?m)^\s*#\s*'" + [regex]::Escape($module) + "'")
            $ApplyText | Should Not Match ("(?m)^\s*'" + [regex]::Escape($module) + "'")
        }
    }

    It 'accepts -NoWait and Wait-ForExit actually honours it' {
        # `update` runs this through gsudo, which shares the caller's console: without the
        # switch the run ends on [Console]::ReadKey and sits there holding the terminal.
        $ApplyText | Should Match '\[switch\]\$NoWait'
        $waitBody = [regex]::Match($ApplyText, '(?s)function Wait-ForExit \{.*?\r?\n\}').Value
        $waitBody | Should Match '\$NoWait'
    }

    It 'has no host-specific configuration selection' {
        $ApplyText | Should Not Match '\$HostName'
        $ApplyText | Should Not Match '\$HostFile'
        $ApplyText | Should Not Match 'hosts[\\/].*windows\.ps1'
        (Test-Path -LiteralPath $ObsoleteHostFile) | Should Be $false
    }
}
