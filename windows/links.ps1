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

    # 'dotfiles.powertoys' absent on purpose: PowerToys is on no host, so the link
    # only created a stray settings.json. The source file stays for when it returns.

    # 'dotfiles.dotpkg' absent after a measurement, not on principle. dotpkg writes
    # its lock with create-then-rename, and a rename REPLACES a symlink with a real
    # file: the link broke on the first `dotpkg update`, the new pin landed in the
    # home-directory copy, and the repo silently stopped receiving updates with
    # `git status` clean throughout.
    #
    # So nothing writable is linked -- packages.dotpkg passes --config/--lock at
    # the committed files instead. The rule that leaves behind: a file some tool
    # REWRITES does not belong behind a symlink into this repo unless that tool is
    # measured to overwrite in place. vim.pack does; dotpkg does not.

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

    # opencode uses the same XDG-shaped layout here as on the nix hosts, so these
    # mirror opencode.d/default.nix one for one. plugin\ is linked whole because
    # opencode.json names it by a path relative to the config directory.
    #
    # mcp\router-search is NOT linked: it is started via `router-search-mcp`, a
    # wrapper only nix builds. Windows logs one failed MCP at startup and carries on.
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

    # Config only -- the binary is NOT installed by apply.ps1: pi self-updates, and
    # under scoop two updaters would write the same path with install.json going
    # stale whenever pi won. It lives at %LOCALAPPDATA%\pi, unpacked from the
    # GitHub release, with that directory on the user PATH.
    #
    # Runs arm64-native on a14, unlike opencode, whose TUI cannot start there.
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

    # 'programs.herdr' absent: it needs a generated config.toml no symlink can
    # express, so it lives in modules/programs/herdr/module.ps1. apply.ps1 checks
    # THIS table first and `continue`s on a hit, so a name here never reaches its
    # module file -- the two are mutually exclusive, not complementary.
}
