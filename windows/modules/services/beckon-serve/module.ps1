@{
    Description = 'Scheduled task: beckon --serve at logon (hotkey host, replaces launch-app.ahk)'
    Apply = {
        param($Ctx)
        $taskName = 'BeckonServe'

        $beckonExe = Get-Command beckon.exe -ErrorAction SilentlyContinue
        if (-not $beckonExe) {
            Write-Warn 'beckon.exe not found (scoop install beckon)'
            return
        }

        $config = Join-Path $Ctx.ConfigsDir 'shortcuts\apps.windows.toml'
        if (-not (Test-Path $config)) {
            Write-Warn "shortcuts config missing: $config"
            return
        }

        # Khong can delay PT15S kieu AHK: beckon dung RegisterHotKey, khong cai
        # hook nao nen khong dua voi VKey/kanata ve thu tu LLHOOK.
        $logDir = Join-Path $env:LOCALAPPDATA 'beckon'
        if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
        $log = Join-Path $logDir 'serve.log'
        # Bọc cmd /c để bắt stderr: sự cố 09/08 mù hoàn toàn vì task không có
        # log — "N shortcuts registered" khi đó là toast đếm parse, không phải
        # bằng chứng. > (ghi đè, không >>): mỗi lần start là một đời serve.
        #
        # conhost --headless đứng trước cmd để KHÔNG sinh cửa sổ. cmd.exe là
        # console app, task chạy LogonType=Interactive (bắt buộc — RegisterHotKey
        # không sống ở session 0), nên Windows cấp console cho nó; và vì máy này
        # để Windows Terminal làm terminal mặc định, console đó được giao vào
        # cửa sổ WT đang mở dưới dạng MỘT TAB MỚI, trông y hệt tab người dùng tự
        # mở. Đóng nhầm tab đó = beckon nhận CTRL_CLOSE_EVENT và chết với
        # 0xC000013A; đã xảy ra thật 09/08/2026, phím tắt chết 4 phút 21 giây
        # cho tới nhịp watchdog kế.
        #
        # Đã đo cả năm cách trên chính máy này trước khi chọn (09/08/2026):
        #   cmd /c                        -> 2 cửa sổ (tab WT + PseudoConsoleWindow)
        #   powershell -WindowStyle Hidden -> VẪN ra tab WT — đừng dùng, đây là
        #                                    cách trông có vẻ đúng nhất mà hỏng
        #   wscript + WshShell.Run(...,0)  -> không cửa sổ (nhưng VBScript đang
        #                                    bị Microsoft cho thoái trào)
        #   AutoHotkey Run(..., "Hide")    -> không cửa sổ (thêm phụ thuộc AHK)
        #   conhost --headless             -> không cửa sổ  <- chọn cái này
        # conhost vẫn ĐỢI tiến trình con (task giữ State=Running, nên
        # "BeckonServe đang Running" vẫn là tín hiệu daemon còn sống) và stderr
        # vẫn vào log. Cờ --headless không có tài liệu chính thức — nếu bản
        # Windows nào đó bỏ nó, hai cách còn lại ở trên là phương án dự phòng.
        #
        # Phép đo phải chạy TRONG session 1: window station tách theo session,
        # nên liệt kê cửa sổ từ phiên SSH (session 0) thấy 0 cửa sổ dù màn hình
        # đầy cửa sổ — âm tính giả đã làm lạc hướng chẩn đoán một lần.
        $userId    = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $action    = New-ScheduledTaskAction -Execute 'conhost.exe' `
            -Argument "--headless cmd /c `"`"$($beckonExe.Source)`" --serve `"$config`" 2> `"$log`"`""
        $trigger   = New-ScheduledTaskTrigger -AtLogon
        $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -ExecutionTimeLimit 0

        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if (Test-ScheduledTaskMatch -Existing $existingTask -Action $action -Trigger $trigger `
                -Principal $principal -Settings $settings) {
            Write-Skip "scheduled task: $taskName"
            return
        }

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
            -Principal $principal -Settings $settings -Force | Out-Null
        Write-OK "scheduled task: $taskName"
    }
}
