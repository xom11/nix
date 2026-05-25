@{
    Description = 'Winget packages (apps + CLI tools, replaces scoop)'
    Apply = {
        param($Ctx)
        Install-WingetPackages @(
            # ---- Apps ----
            'Brave.Brave'
            'Discord.Discord'
            'Google.Chrome'
            'Microsoft.VisualStudioCode'
            'Obsidian.Obsidian'
            'Tailscale.Tailscale'
            'VNGCorp.Zalo'
            '9PFXXSHC64H3'                # Raycast (Microsoft Store)

            # ---- Terminals / shells ----
            'Microsoft.PowerShell'
            'wez.wezterm'
            'JanDeDobbeleer.OhMyPosh'

            # ---- Fonts ----
            'DEVCOM.JetBrainsMonoNerdFont'

            # ---- System / elevation ----
            'AutoHotkey.AutoHotkey'
            'gerardog.gsudo'              # optional, for de-elevation in shell
            '7zip.7zip'                   # used by scoop (7zipextract_use_external) on ARM64

            # ---- Dev CLI (moved from scoop) ----
            'Git.Git'
            'OpenJS.NodeJS'
            'GitHub.cli'
            'sharkdp.bat'
            'BurntSushi.ripgrep.MSVC'
            'junegunn.fzf'
            'Fastfetch-cli.Fastfetch'
            'Neovim.Neovim'
            'JesseDuffield.lazygit'
            'JesseDuffield.Lazydocker'
            'sxyazi.yazi'
            'sigoden.AIChat'
            'mvdan.shfmt'

            # ---- Services / utilities ----
            'Syncthing.Syncthing'
        )
    }
}
