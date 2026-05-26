param($Ctx)

$Hm = $Ctx.HomeManagerDir

@{
    # ---- dotfiles (all shared from home-manager/dotfiles) ----
    'dotfiles.pwsh' = @(
        @{ Source = "$Hm\dotfiles\windows\pwsh\Microsoft.PowerShell_profile.ps1"
           Target = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" }
        @{ Source = "$Hm\dotfiles\windows\pwsh\ps1.d"
           Target = "$env:USERPROFILE\Documents\PowerShell\ps1.d" }
    )

    'dotfiles.windows-terminal' = @(
        @{ Source = "$Hm\dotfiles\windows\WindowsTerminal\settings.json"
           Target = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" }
    )

    'dotfiles.powertoys' = @(
        @{ Source = "$Hm\dotfiles\windows\PowerToys\settings.json"
           Target = "$env:LOCALAPPDATA\Microsoft\PowerToys\settings.json" }
    )

    'dotfiles.vscode' = @(
        @{ Source = "$Hm\dotfiles\vscode\settings.json"
           Target = "$env:APPDATA\Code\User\settings.json" }
        @{ Source = "$Hm\dotfiles\vscode\keybindings.json"
           Target = "$env:APPDATA\Code\User\keybindings.json" }
    )

    'dotfiles.terminal.wezterm' = @(
        @{ Source = "$Hm\dotfiles\terminal\wezterm\wezterm.lua"
           Target = "$env:USERPROFILE\.config\wezterm\wezterm.lua" }
    )

    'dotfiles.ai.claude' = @(
        @{ Source = "$Hm\dotfiles\ai\claude.d\CLAUDE.md"
           Target = "$env:USERPROFILE\.claude\CLAUDE.md" }
        @{ Source = "$Hm\dotfiles\ai\claude.d\settings.json"
           Target = "$env:USERPROFILE\.claude\settings.json" }
        @{ Source = "$Hm\dotfiles\ai\claude.d\commands"
           Target = "$env:USERPROFILE\.claude\commands" }
    )

    'dotfiles.ai.codex' = @(
        @{ Source = "$Hm\dotfiles\ai\codex.d\AGENTS.md"
           Target = "$env:USERPROFILE\.codex\AGENTS.md" }
        @{ Source = "$Hm\dotfiles\ai\codex.d\config.toml"
           Target = "$env:USERPROFILE\.codex\config.toml" }
    )

    'dotfiles.ai.gemini' = @(
        @{ Source = "$Hm\dotfiles\ai\gemini.d\GEMINI.md"
           Target = "$env:USERPROFILE\.gemini\GEMINI.md" }
    )

    'dotfiles.ai.aichat' = @(
        @{ Source = "$Hm\dotfiles\ai\aichat.d\roles"
           Target = "$env:APPDATA\aichat\roles" }
    )

    'programs.ssh' = @(
        @{ Source = "$Hm\programs\ssh\config"
           Target = "$env:USERPROFILE\.ssh\config" }
    )

    'programs.nvim' = @(
        @{ Source = "$Hm\programs\nvim\lua\init.lua"
           Target = "$env:LOCALAPPDATA\nvim\init.lua" }
        @{ Source = "$Hm\programs\nvim\lua"
           Target = "$env:LOCALAPPDATA\nvim\lua" }
    )

    'programs.yazi' = @(
        @{ Source = "$Hm\programs\yazi\yazi.d"
           Target = "$env:APPDATA\yazi\config" }
    )
}
