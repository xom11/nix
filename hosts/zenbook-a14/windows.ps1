@{
    Modules = @(
        # ---- packages ----
        'packages.winget'             # all apps + CLI tools (replaces scoop)
        'packages.psmodules'          # PowerShell modules
        'packages.npm'                # global npm packages (needs nodejs from winget)
        # scoop-only packages (kanata, stylua, im-select, yamlfmt) installed
        # separately by user: windows\scripts\install-scoop.ps1 (non-admin)

        # ---- dotfiles (Windows-native) ----
        'dotfiles.pwsh'
        'dotfiles.windows-terminal'
        'dotfiles.powertoys'

        # ---- dotfiles (shared with home-manager) ----
        'dotfiles.vscode'
        'dotfiles.terminal.wezterm'
        'dotfiles.ai.claude'
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
