@{
    Description = 'Neuter the Windows Office/Hyper key so Ctrl+Win+Alt+Shift combos can serve beckon'
    Apply = {
        param($Ctx)

        # Windows dang ky san chord Office key (Ctrl+Win+Alt+Shift+<chu>) cho bo
        # app Office — do 09/08/2026 tren a14: `Cap+Shift+D` cua beckon serve bi
        # "Hot key is already registered" va bam ra OneDrive. De ms-officeapp
        # handler thanh rundll32 no-op la cach cong dong da kiem chung
        # (answers.microsoft.com qua office-watch.com):
        #   - Hieu luc NGAY: bam chord khong mo app Office nao nua.
        #   - Dang ky hotkey chi duoc nha o lan LOGON ke tiep (restart Explorer
        #     khong du — da do truc tiep). Kiem sau reboot: serve.log khong con
        #     dong "cannot register `ctrl+super+alt+shift+d`" la xong.
        $key = 'HKCU:\Software\Classes\ms-officeapp\Shell\Open\Command'
        $want = 'rundll32'

        $current = (Get-ItemProperty -Path $key -Name '(default)' -ErrorAction SilentlyContinue).'(default)'
        if ($current -eq $want) {
            Write-Skip 'ms-officeapp handler already neutered'
            return
        }

        New-Item -Path $key -Force | Out-Null
        Set-ItemProperty -Path $key -Name '(default)' -Value $want
        Write-OK 'ms-officeapp handler -> rundll32 (Office key chords neutered; hotkey slots free after next logon)'
    }
}
