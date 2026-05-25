@{
    Description = 'Winget: GUI apps + system tools + CLI dev tools (scoop ARM64 has shim bugs)'
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
            # 'VNGCorp.Zalo'              # winget download keeps failing (0x80072f05); install manually
            '9PFXXSHC64H3'                # Raycast (Microsoft Store)

            # ---- Terminals / shells ----
            'Microsoft.PowerShell'
            'wez.wezterm'
            'JanDeDobbeleer.OhMyPosh'

            # ---- Fonts ----
            'DEVCOM.JetBrainsMonoNerdFont'

            # ---- System / elevation ----
            'AutoHotkey.AutoHotkey'
            'gerardog.gsudo'              # for de-elevation in shell + scoop bootstrap
            '7zip.7zip'                   # used by scoop (7zipextract_use_external)
            'ajeetdsouza.zoxide'          # used by pwsh profile

            # ---- CLI dev tools ----
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

            # ---- Service ----
            'Syncthing.Syncthing'
        )
    }
}
