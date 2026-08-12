Describe 'windows/apply.ps1 shared entry point' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ApplyText = Get-Content -LiteralPath (Join-Path $RepoRoot 'windows\apply.ps1') -Raw
        $ObsoleteHostFile = Join-Path $RepoRoot 'hosts\zenbook-a14\windows.ps1'
        $ExpectedModules = @(
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

    It 'has no dotfiles.dotpkg module, because nothing is linked for dotpkg' {
        # There was one, for two hours on 2026-08-12. It linked pkg.toml and
        # pkg.lock into %USERPROFILE%, and packages.dotpkg read them there.
        # dotpkg writes the lock with File::create + fs::rename, and a rename
        # replaces a symlink with a regular file -- measured on a14: the link
        # became a real file on the first `dotpkg update`, the new pin landed in
        # the home directory, and the repo stopped receiving updates with
        # `git status` clean throughout.
        #
        # This asserts the absence so the entry does not come back by reflex.
        # The name is quoted and line-anchored, so the explanatory comments in
        # apply.ps1 and links.ps1 do not satisfy it.
        $ApplyText | Should Not Match "(?m)^\s*'dotfiles\.dotpkg'"
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
