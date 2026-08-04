@{
    Description = 'Apply brave.toml: shortcuts, settings, force-installed PWAs'
    Apply = {
        param($Ctx)

        # Cung mot file voi may Nix. Khong copy, khong ban Windows rieng.
        $toml = Join-Path $Ctx.HomeManagerDir 'dotfiles\browser\dotbrave\brave.toml'
        if (-not (Test-Path -LiteralPath $toml)) {
            throw "brave.toml not found at $toml"
        }

        if (-not (Get-Command uvx -ErrorAction SilentlyContinue)) {
            Write-Skip 'dotbrave -> uvx khong co (scoop install uv)'
            return
        }

        # PyPI gio da co dotbrave >= 0.3.3, kem --unattended va --skip: repo
        # thuong nguon co workflow "Publish to PyPI" chay tren moi push vao
        # main nen da bat kip ban tag moi nhat (kiem lai bang
        # `pip index versions dotbrave` truoc khi doi qua day, dung tin theo
        # tri nho). Chuyen tu git sang PyPI vi PyPI phat hanh wheel dung san:
        # uvx chi tai wheel va giai nen, khong resolve+build tu source tren
        # dia moi lan chay nhu duong git truoc do -- do chinh la phan cham
        # nhat cua buoc nay, va da do thuc te tren a14 qua SSH: lan chay dau
        # va lan chay sau deu nhanh hon ro ret so voi duong git.
        #
        # Van ghim dung phien ban, khong de `uvx dotbrave` tu lay ban moi
        # nhat. Day dung la vai tro flake.lock dang giu cho may Nix, chi la o
        # phia Windows: khong ghim thi moi ban phat hanh moi cua thuong nguon
        # deu chay thang vao mot script dang co quyen Administrator va ghi
        # HKLM policy -- khong ai duyet, khong dau vet lai. Nang so nay la
        # viec co y, lam khi dotbrave ra ban moi.
        $src = 'dotbrave==0.3.3'

        # KHONG co --skip pwa o day, khac han may Nix: ben do co mot module
        # Nix so huu managed policy nen CLI phai tranh ra, con o day khong co
        # Nix va apply.ps1 von chay quyen Administrator, nen CLI duoc phep
        # ghi HKLM.
        #
        # "Duoc phep" khong dong nghia "lam duoc ca ba". --unattended khong
        # bao gio dong Brave, nen bang nao thuc su duoc ap la tuy trang thai
        # Brave luc chay:
        #   Brave dang dong -> ca ba bang (backup, ghi Preferences, verify).
        #   Brave dang mo va co DevTools endpoint -> [pwa] ghi thang vao
        #     HKLM; [shortcuts]/[settings] ap live qua endpoint do.
        #   Brave dang mo, khong co endpoint -- trang thai binh thuong o may
        #     nay, vi khong co gi khoi dong Brave kem --remote-debugging-port
        #     -> chi [pwa] duoc ghi. Hai bang kia bi bo lai, CLI in ra stderr
        #     dang "[pwa] applied; [shortcuts] not applied", va van exit 0.
        #
        # Nen dong Write-OK cuoi khoi nay chi noi "lenh khong loi", khong noi
        # "ca ba bang da vao". Muon ca ba thi dong Brave roi chay lai update.
        # Truoc dotbrave v0.3.2 con te hon: mot [shortcuts] ban lam [pwa] bi
        # bo luon, im lang va exit 0 -- do la ly do cua cai ghim phien ban
        # o tren.
        Write-Info "dotbrave -> apply $toml"

        # 'Continue' trong pham vi khoi nay: ngay ca cai tu wheel dung san
        # tren PyPI, uv van in tien do resolve/tai ve ra stderr -- do thuc te
        # tren a14 cho thay dong stderr khong rong ngay ca o lan chay dau.
        # Duoi $ErrorActionPreference = 'Stop' (apply.ps1 dat o pham vi
        # script), moi dong stderr cua native command deu thanh ErrorRecord
        # roi thanh terminating exception trong Windows PowerShell 5.1 --
        # cuop mat nhanh doc $LASTEXITCODE ngay ben duoi du dotbrave chay
        # thanh cong, va lam LASTEXITCODE ro sang module ke tiep, dung dieu
        # comment o duoi noi no ngan. Secrets.psm1:74-76 va
        # githooks/module.ps1:28,36 da phai xu ly dung bay nay cho cac lenh
        # it kha nang ghi stderr hon uvx nhieu.
        $ErrorActionPreference = 'Continue'
        & uvx --from $src dotbrave apply --unattended $toml

        # $LASTEXITCODE la bien toan cuc cua ca tien trinh: doc roi reset ngay,
        # neu khong no ro sang module sau va lam do ca apply.ps1.
        $rc = $LASTEXITCODE
        $global:LASTEXITCODE = 0

        if ($rc -ne 0) {
            throw "dotbrave apply exited $rc"
        }
        Write-OK 'dotbrave -> apply ran (stderr names any table left unapplied)'
    }
}
