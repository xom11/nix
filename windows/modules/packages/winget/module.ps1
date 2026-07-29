@{
    Description = 'Winget: GUI apps + system tools + fonts (all CLI dev tools live in scoop)'
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
            'Vivaldi.Vivaldi'
            # 'VNGCorp.Zalo'              # winget download fails (0x80072f05); install manually
            '9PFXXSHC64H3'                # Raycast (Microsoft Store)
            'Warp.Warp'

            # ---- Terminals / shells ----
            'Microsoft.PowerShell'
            'wez.wezterm'
            'JanDeDobbeleer.OhMyPosh'
            'ajeetdsouza.zoxide'

            # ---- Fonts ----
            'DEVCOM.JetBrainsMonoNerdFont'

            # ---- System tools ----
            '7zip.7zip'
            'AutoHotkey.AutoHotkey'
            'gerardog.gsudo'              # de-elevation in shell (sudo equivalent)
            'PhatMT97.VKey'               # Vietnamese IME; ahk/evkey-monitor.ahk watches it

            # ---- Service ----
            'Syncthing.Syncthing'         # installed on demand; the logon task is disabled in apply.ps1
        )
    }
}
