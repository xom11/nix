Describe 'windows/apply.ps1 shared entry point' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ApplyText = Get-Content -LiteralPath (Join-Path $RepoRoot 'windows\apply.ps1') -Raw
        $ObsoleteHostFile = Join-Path $RepoRoot 'hosts\zenbook-a14\windows.ps1'
        $ExpectedModules = @(
            'packages.winget'
            'packages.pwsh'
            'packages.scoop'
            'packages.psmodules'
            'packages.npm'
            'dotfiles.pwsh'
            'dotfiles.windows-terminal'
            'dotfiles.vscode'
            'dotfiles.terminal.wezterm'
            'dotfiles.ai.claude'
            'dotfiles.ai.codex'
            'dotfiles.ai.gemini'
            'dotfiles.ai.aichat'
            'programs.ssh'
            'programs.nvim'
            'programs.yazi'
            'services.kanata'
            'services.kanata-watchdog'
            'services.ahk'
            'services.sshd'
        )
        # Kept in the file as commented-out entries so the reason survives; they must not be
        # silently active. The plain-substring assertion below cannot tell the two apart, so
        # these get their own check.
        $DisabledModules = @(
            'dotfiles.powertoys'
            'services.syncthing'
        )
    }

    It 'owns the single Windows module selection directly' {
        foreach ($module in $ExpectedModules) {
            # (?m) so ^ anchors per line -- PowerShell's -match is single-line by default.
            $ApplyText | Should Match ("(?m)^\s*'" + [regex]::Escape($module) + "'")
        }
    }

    It 'keeps disabled modules commented out rather than active' {
        foreach ($module in $DisabledModules) {
            $ApplyText | Should Match ("(?m)^\s*#\s*'" + [regex]::Escape($module) + "'")
            $ApplyText | Should Not Match ("(?m)^\s*'" + [regex]::Escape($module) + "'")
        }
    }

    It 'has no host-specific configuration selection' {
        $ApplyText | Should Not Match '\$HostName'
        $ApplyText | Should Not Match '\$HostFile'
        $ApplyText | Should Not Match 'hosts[\\/].*windows\.ps1'
        (Test-Path -LiteralPath $ObsoleteHostFile) | Should Be $false
    }
}
