@{
    Description = 'Scheduled task: beckon serve at logon (hotkey host, replaces launch-app.ahk)'
    Apply = {
        param($Ctx)
        $taskName = 'BeckonServe'

        $beckonExe = Get-Command beckon.exe -ErrorAction SilentlyContinue
        if (-not $beckonExe) {
            Write-Warn 'beckon.exe not found (scoop install beckon)'
            return
        }

        $config = Join-Path $Ctx.ConfigsDir 'shortcuts\apps.shared.toml'
        if (-not (Test-Path $config)) {
            Write-Warn "shortcuts config missing: $config"
            return
        }

        # Khong can delay PT15S kieu AHK: beckon dung RegisterHotKey, khong cai
        # hook nao nen khong dua voi VKey/kanata ve thu tu LLHOOK.
        # Khong con New-Item cho thu muc log: beckon --log tu tao thu muc cha.
        $log = Join-Path (Join-Path $env:LOCALAPPDATA 'beckon') 'serve.log'
        # cmd /c da bi bo (09/08/2026, beckon 0.5.3): beckon co co --log, tu
        # chuyen huong stderr bang SetStdHandle roi goi FreeConsole. Bat stderr
        # van la bat buoc — su co 09/08 mu hoan toan vi task khong co log.
        #
        # DOI HANH VI: --log GHI TIEP (append), khong ghi de nhu `2>` truoc day.
        # Co y: RestartOnFailure tung xoa dung cai log giai thich vi sao no phai
        # restart. Doi lai, file khong tu co lai nua — serve.log moi doi serve
        # them mot dong, khong dang ke.
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
        #
        # Do lai lan hai sau khi beckon co --log (09/08/2026, trong session 1,
        # 5 dang, lay mau 25ms/lan, co doi chung):
        #   beckon tran (khong --log)      -> tab WT + PseudoConsoleWindow, CA HAI
        #                                    TON TAI VINH VIEN
        #   beckon --log                   -> tab WT hien o 148ms, MAT o 210ms;
        #                                    khong con gi dong lai
        #   conhost --headless + --log     -> KHONG CO CUA SO NAO  <- van la nay
        # Tuc la --log tu no da du de khong con cua so DONG LAI, nhung van nhay
        # ~60ms vi Windows cap console TRUOC khi main() chay — FreeConsole chi
        # dong duoc no sau do. conhost --headless chan tu dau, nen giu.
        #
        # CANH BAO neu sau nay bo conhost: action phai tro thang vao
        # scoop\apps\beckon\current\beckon.exe, KHONG phai scoop\shims\beckon.exe.
        # Shim la mot tien trinh cha con song (do duoc: pid shim la
        # ParentProcessId cua beckon that), nen no van giu console va FreeConsole
        # cua beckon se khong dong duoc cua so. Voi conhost o dau thi shim vo hai.
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
            -Argument "--headless `"$($beckonExe.Source)`" serve `"$config`" --log `"$log`""
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
