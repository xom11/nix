Describe 'windows/apply.ps1 shared entry point' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ApplyText = Get-Content -LiteralPath (Join-Path $RepoRoot 'windows\apply.ps1') -Raw
        $ObsoleteHostFile = Join-Path $RepoRoot 'hosts\zenbook-a14\windows.ps1'
        $ExpectedModules = @(
            'packages.winget'
            'packages.scoop'
            'packages.psmodules'
            'packages.npm'
            'dotfiles.pwsh'
            'dotfiles.windows-terminal'
            'dotfiles.powertoys'
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
            'services.ahk'
            'services.syncthing'
            'services.sshd'
        )
    }

    It 'owns the single Windows module selection directly' {
        foreach ($module in $ExpectedModules) {
            $ApplyText | Should Match ([regex]::Escape("'$module'"))
        }
    }

    It 'has no host-specific configuration selection' {
        $ApplyText | Should Not Match '\$HostName'
        $ApplyText | Should Not Match '\$HostFile'
        $ApplyText | Should Not Match 'hosts[\\/].*windows\.ps1'
        (Test-Path -LiteralPath $ObsoleteHostFile) | Should Be $false
    }
}
