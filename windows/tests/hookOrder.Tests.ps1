Describe 'windows kanata/VKey hook order (evkey-monitor.ahk)' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $AhkDir   = Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk'
        $Monitor  = Get-Content -Raw -LiteralPath (Join-Path $AhkDir 'evkey-monitor.ahk')
        $Main     = Get-Content -Raw -LiteralPath (Join-Path $AhkDir 'main.ahk')
    }

    It 'is actually loaded by main.ahk' {
        # Mot monitor khong duoc #Include thi im lang va vo dung.
        $Main | Should Match ([regex]::Escape('#Include evkey-monitor.ahk'))
    }

    It 'covers all three moments VKey may re-register its LL hook' {
        # User-mode khong co API nao liet ke chain WH_KEYBOARD_LL, nen ba thoi diem nay la
        # tat ca nhung gi ta doan duoc. Bo sot mot cai = thu tu dao am tham.
        # 1. tien trinh VKey vua len
        $Monitor | Should Match ([regex]::Escape('ProcessExist("VKey.exe")'))
        # 2. mo khoa may
        $Monitor | Should Match '0x02B1'
        $Monitor | Should Match 'WTS_SESSION_UNLOCK\s*:=\s*0x8'
        # 3. thuc tu sleep
        $Monitor | Should Match '0x0218'
        $Monitor | Should Match 'PBT_APMRESUMEAUTOMATIC\s*:=\s*0x12'
    }

    It 'registers for session notifications, otherwise unlock never arrives' {
        # Khong co WTSRegisterSessionNotification thi WM_WTSSESSION_CHANGE khong bao gio
        # duoc gui toi cua so cua script, va nhanh unlock thanh code chet.
        $Monitor | Should Match 'WTSRegisterSessionNotification'
        $Monitor | Should Match 'A_ScriptHwnd'
    }

    It 'debounces so wake+unlock do not restart kanata twice' {
        # Wake va unlock gan nhu luon ban lien nhau, ma moi lan restart kanata la mot nhip
        # rot phim.
        $Monitor | Should Match '__vk_debounce'
        $Monitor | Should Match 'A_TickCount\s*-\s*__vk_lastRequest'
    }

    It 'delays on unlock/resume but not when VKey just appeared' {
        # Nhanh process: da BIET VKey vua len -> restart ngay.
        $Monitor | Should Match ([regex]::Escape('RequestKanataRestart()'))
        # Nhanh unlock/resume: VKey co the dang ky lai hook cham hon ta mot nhip, restart
        # som se bi no chen len tren lai.
        $Monitor | Should Match ([regex]::Escape('RequestKanataRestart(__vk_settleDelay)'))
        $Monitor | Should Match '__vk_settleDelay\s*:=\s*\d+'
    }

    It 'goes through the elevated Kanata task, not a direct kanata launch' {
        # Task "Kanata" chay launch-kanata.ahk khong tham so = force restart, va chi Task
        # Scheduler moi cap duoc admin context can thiet de cai lai hook.
        $Monitor | Should Match ([regex]::Escape('schtasks /run /tn "Kanata"'))
        $Monitor | Should Not Match 'kanata_windows_'
    }

    It 'records why wintercept is not an option on this hardware' {
        # a14-win la ARM64; build wintercept can driver kernel x64 cua Interception ma
        # Windows on ARM khong nap noi. Ghi lai de lan sau khong ai de xuat lai roi lai
        # mat mot buoi do.
        $Monitor | Should Match 'ARM64'
        $Monitor | Should Match 'wintercept'
    }
}
