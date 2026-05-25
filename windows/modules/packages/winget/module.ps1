@{
    Description = 'Winget: GUI apps, system tools, fonts, plus git/nodejs (NSIS/MSI installers scoop ARM64 cant extract)'
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
            # 'VNGCorp.Zalo'              # winget download fails (0x80072f05); install manually
            '9PFXXSHC64H3'                # Raycast (Microsoft Store)

            # ---- Terminals / shells ----
            'Microsoft.PowerShell'
            'wez.wezterm'
            'JanDeDobbeleer.OhMyPosh'
            'ajeetdsouza.zoxide'          # used by pwsh profile

            # ---- Fonts ----
            'DEVCOM.JetBrainsMonoNerdFont'

            # ---- System / elevation ----
            'AutoHotkey.AutoHotkey'
            'gerardog.gsudo'              # de-elevation for scoop
            '7zip.7zip'                   # required: scoop pulls 7z.exe from here to patch its broken ARM64 7zip manifest

            # ---- NSIS-only on ARM64, scoop cant extract ----
            'Git.Git'
            'OpenJS.NodeJS'

            # ---- Service ----
            'Syncthing.Syncthing'
        )
    }
}
