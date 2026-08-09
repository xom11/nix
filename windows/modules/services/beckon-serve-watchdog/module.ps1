@{
    Description = 'Scheduled task: restart beckon --serve if it dies between logons'
    Apply = {
        param($Ctx)
        $taskName = 'BeckonServeWatchdog'

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

        # KHAC AHKWatchdog, khong can launcher script -- action la CHINH lenh serve;
        # khi service dang song, instance moi bi lock don-instance cua beckon da ra
        # nen watchdog la no-op; khi chet, lan lap ke khoi dong lai. (Cung ly do,
        # chay tay `beckon --serve` tren file that cung vo hai -- lock chan.)
        #
        # LastTaskResult cua task nay KHONG con y nghia tu khi bo conhost vao
        # truoc (09/08/2026): Task Scheduler nhan exit code cua conhost, luon la
        # 0x0, chu khong phai exit 1 cua beckon. Truoc do 0x1 = "bi tu choi lock"
        # = khoe; bay gio 0x0 xuat hien ca khi probe bi tu choi lan khi no vua
        # dung len mot serve moi. Bang chung duy nhat con lai la serve-watchdog.log
        # duoi day -- doc NOI DUNG no, va doc mtime de biet nhip probe con chay.
        $logDir = Join-Path $env:LOCALAPPDATA 'beckon'
        if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
        $log = Join-Path $logDir 'serve-watchdog.log'
        # Bọc cmd /c để bắt stderr: sự cố 09/08 mù hoàn toàn vì task không có
        # log — "N shortcuts registered" khi đó là toast đếm parse, không phải
        # bằng chứng. > (ghi đè, không >>): mỗi lần start là một đời serve.
        # Watchdog probe nào serve dang song thi file nay chi chua dong tu-choi-lock
        # — do la dau hieu KHOE; serve.log la cua task chinh, watchdog khong duoc dung.
        # conhost --headless: xem giai thich day du trong module beckon-serve.
        # Tom tat — cmd.exe la console app + task chay Interactive + may nay de
        # Windows Terminal lam terminal mac dinh => moi lan chay sinh MOT TAB WT
        # moi. Watchdog chay 5 phut/lan nen no la thu phat sinh tab nhieu nhat,
        # va khi watchdog phai dung len giu serve (da xay ra) thi tab do song
        # mai. `powershell -WindowStyle Hidden` KHONG cuu duoc — da do.
        $userId    = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $action    = New-ScheduledTaskAction -Execute 'conhost.exe' `
            -Argument "--headless cmd /c `"`"$($beckonExe.Source)`" --serve `"$config`" 2> `"$log`"`""
        $trigger   = New-ScheduledTaskTrigger -Once -At '2020-01-01T00:00:00' `
            -RepetitionInterval (New-TimeSpan -Minutes 5)
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
