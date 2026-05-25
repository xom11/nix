@{
    Modules = @(
        # ---- packages ----
        'packages.winget'             # all apps + CLI tools + 7zip + gsudo
        'packages.scoop'              # non-winget packages (auto de-elevates via gsudo)
        'packages.psmodules'          # PowerShell modules
        'packages.npm'                # global npm packages (needs nodejs from winget)

        # ---- dotfiles (Windows-native) ----
        'dotfiles.pwsh'
        'dotfiles.windows-terminal'
        'dotfiles.powertoys'

        # ---- dotfiles (shared with home-manager) ----
        'dotfiles.vscode'
        'dotfiles.terminal.wezterm'
        'dotfiles.ai.claude'
        'dotfiles.ai.codex'
        'dotfiles.ai.gemini'
        'dotfiles.ai.aichat'

        # ---- programs (shared with home-manager) ----
        'programs.ssh'
        'programs.nvim'
        'programs.yazi'

        # ---- services (scheduled tasks) ----
        'services.ahk'
        'services.syncthing'
    )
}
