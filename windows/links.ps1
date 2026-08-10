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

    # 'dotfiles.powertoys' is intentionally absent: PowerToys is not installed on any host, so
    # the link only created a stray settings.json. The source file is kept in the repo for when
    # PowerToys comes back -- re-add the entry here and to $modules in apply.ps1 at that point.

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

    # opencode keeps the same XDG-shaped layout on Windows as it does on the nix hosts --
    # `opencode debug paths` reports config at %USERPROFILE%\.config\opencode -- so these targets
    # mirror home-manager/dotfiles/ai/opencode.d/default.nix one for one.
    #
    # plugin\ is linked as a whole directory because opencode.json refers to the plugin by the
    # relative path "./plugin/router-models.mjs", which resolves against the config directory.
    #
    # mcp\router-search is deliberately NOT linked: opencode.json starts that server by running
    # `router-search-mcp`, a wrapper that only exists where nix builds it (writeShellScriptBin in
    # opencode.d/default.nix). Windows has no such command, so opencode logs one failed MCP at
    # startup and carries on. The other servers, the 9router provider and the model all work.
    'dotfiles.ai.opencode' = @(
        @{ Source = "$Hm\dotfiles\ai\opencode.d\opencode.json"
           Target = "$env:USERPROFILE\.config\opencode\opencode.json" }
        @{ Source = "$Hm\dotfiles\ai\opencode.d\tui.json"
           Target = "$env:USERPROFILE\.config\opencode\tui.json" }
        @{ Source = "$Hm\dotfiles\ai\opencode.d\OPENCODE.md"
           Target = "$env:USERPROFILE\.config\opencode\OPENCODE.md" }
        @{ Source = "$Hm\dotfiles\ai\opencode.d\plugin"
           Target = "$env:USERPROFILE\.config\opencode\plugin" }
    )

    # Config only -- the pi binary is NOT installed by apply.ps1, on purpose.
    #
    # pi ships `pi update --self` and keeps itself current from its own releases, the same
    # arrangement claude (%USERPROFILE%\.local\bin) and agy (%LOCALAPPDATA%\agy) already have
    # on this machine. Putting it under scoop instead would mean two updaters writing the
    # same binary, with scoop's install.json quietly going stale every time pi won.
    #
    # So it lives at %LOCALAPPDATA%\pi, unpacked from the GitHub release, with that directory
    # on the user PATH. On a machine that has never had it: grab pi-windows-<arch>.zip from
    # github.com/earendil-works/pi/releases, unpack it there, add the directory to PATH.
    #
    # Verified working on a14 (arm64 native, PE machine 0xAA64) -- unlike opencode, whose TUI
    # cannot start on Windows-on-ARM at all.
    'dotfiles.ai.pi' = @(
        @{ Source = "$Hm\dotfiles\ai\pi.d\settings.json"
           Target = "$env:USERPROFILE\.pi\agent\settings.json" }
        @{ Source = "$Hm\dotfiles\ai\pi.d\models.json"
           Target = "$env:USERPROFILE\.pi\agent\models.json" }
        @{ Source = "$Hm\dotfiles\ai\pi.d\AGENTS.md"
           Target = "$env:USERPROFILE\.pi\agent\AGENTS.md" }
        @{ Source = "$Hm\dotfiles\ai\pi.d\extensions"
           Target = "$env:USERPROFILE\.pi\agent\extensions" }
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

    # 'programs.herdr' is deliberately absent from this table. It needs a generated config.toml
    # (the shared file plus a Windows-only default_shell) which no symlink can express, so it
    # lives in modules/programs/herdr/module.ps1 instead. Note apply.ps1 checks THIS table
    # first and `continue`s on a hit -- a name listed here never reaches its module file, so a
    # module and a link entry are mutually exclusive, not complementary.
}
