@{
    Description = 'Winget: GUI apps + system-level tools + fonts (CLI dev tools live in scoop module)'
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
            '7zip.7zip'                   # used by scoop (7zipextract_use_external) on ARM64

            # ---- Service ----
            'Syncthing.Syncthing'
        )
    }
}
