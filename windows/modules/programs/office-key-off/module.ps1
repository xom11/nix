@{
    Description = 'Neuter the Windows Office/Hyper key so Ctrl+Win+Alt+Shift combos can serve beckon'
    Apply = {
        param($Ctx)

        # Windows dang ky san CHORD OFFICE KEY = Ctrl+Win+Alt+Shift+<chu> cho bo
        # app Office (W=Word X=Excel P=PowerPoint O=Outlook T=Teams D=OneDrive
        # N=OneNote L=LinkedIn Y=Yammer) — trung khit lop Cap+Shift cua kanata,
        # nen moi chu trong bo do la mot slot beckon serve KHONG dang ky duoc
        # ("Hot key is already registered"; do 09/08/2026 voi shift+d/OneDrive).
        # Muc tieu module nay: giai phong CA BO cho lop Cap+Shift.
        #
        # De ms-officeapp handler thanh rundll32 no-op la cach cong dong da kiem
        # chung (answers.microsoft.com qua office-watch.com) — MOT value phu ca
        # bo vi moi chu deu launch qua cung protocol nay:
        #   - Hieu luc NGAY: bam chord khong mo app Office nao nua.
        #   - Slot dang ky hotkey chi duoc NHA o lan LOGON ke tiep (restart
        #     Explorer khong du — da do truc tiep 09/08/2026). Kiem sau logon:
        #     them binding shift+<chu Office> vao apps.windows.toml roi xem
        #     serve.log khong con "cannot register" la bo da tu do.
        #   - Neu sau logon van bi giu: plan B da tinh san — doi lop Cap+Shift
        #     cua kanata_windows sang chord khac (vd ctrl+alt+shift, bo Win)
        #     va sua combo trong apps.windows.toml theo; khong danh nhau voi
        #     Windows nua.
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
