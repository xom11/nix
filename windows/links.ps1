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

    # Config only -- the herdr binary is NOT installed by apply.ps1, for the same reason
    # dotfiles.ai.pi is config-only: herdr ships `herdr update` and `herdr channel` and keeps
    # itself current from its own release feed. A second installer writing the same path would
    # be two updaters racing, and whichever ran last would win.
    #
    # That is the opposite of the nix hosts, where home-manager/programs/herdr owns the binary
    # via pkgs.herdr and therefore gives `herdr update` up -- a read-only store path cannot be
    # replaced. Windows has no such constraint, so the self-updater is kept.
    #
    # One-time install on a machine that has never had it -- note Windows is PREVIEW-ONLY, the
    # installer errors out on `-Channel stable`:
    #   $env:HERDR_CHANNEL='preview'; irm https://herdr.dev/install.ps1 | iex
    # It lands in %LOCALAPPDATA%\Programs\Herdr\bin and puts that directory first on the user
    # PATH via HKCU\Environment. No admin needed.
    #
    # `herdr --remote macmini` only works when both ends speak the same wire protocol, and the
    # protocol number moves with the release: 0.7.3 is protocol 16, 0.8.0-preview is 19. Since
    # Windows is preview-only, the two machines cannot meet on stable -- pinning the mac side to
    # nixpkgs (which tracks stable, and lags it) makes remote attach impossible by construction.
    # So both ends have to ride the same self-updating preview build. Check with
    # `herdr status client` on one and `herdr status server` on the other before debugging
    # anything else; a protocol mismatch is the first thing to rule out.
    #
    # Upstream publishes no ARM64 Windows build: install.ps1 maps Arm64 to windows-x86_64 and
    # says so out loud ("installing the x86_64 build under Windows emulation"). On a14 herdr
    # therefore runs under Prism -- verified by PE header (machine 0x8664), deliberate, and the
    # same accepted trade-off as kanata and rustup. The bundled ConPTY does ship an arm64
    # OpenConsole.exe, so the pty layer itself is native.
    #
    # Individual FILES, never the %APPDATA%\herdr directory: the running server keeps
    # herdr.sock, session.json and herdr*.log in there. Same rule as the nix module.
    'programs.herdr' = @(
        @{ Source = "$Hm\programs\herdr\herdr.d\config.toml"
           Target = "$env:APPDATA\herdr\config.toml" }
        @{ Source = "$Hm\programs\herdr\herdr.d\agent-detection\claude.toml"
           Target = "$env:APPDATA\herdr\agent-detection\claude.toml" }
    )
}
