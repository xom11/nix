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

        # Chay tu git chu khong phai PyPI: PyPI moi co 0.2.5, chua co
        # --unattended lan --skip. `uvx dotbrave` se lay nham ban do va
        # chet ngay o dong lenh.
        $src = 'git+https://github.com/xom11/dotbrave'

        # KHONG co --skip pwa o day, khac han may Nix. Ben do mot module Nix
        # so huu managed policy nen CLI phai tranh ra. O day khong co Nix, va
        # apply.ps1 von da chay quyen Administrator, nen CLI lam ca ba bang.
        Write-Info "dotbrave -> apply $toml"
        & uvx --from $src dotbrave apply --unattended $toml

        # $LASTEXITCODE la bien toan cuc cua ca tien trinh: doc roi reset ngay,
        # neu khong no ro sang module sau va lam do ca apply.ps1.
        $rc = $LASTEXITCODE
        $global:LASTEXITCODE = 0

        if ($rc -ne 0) {
            throw "dotbrave apply exited $rc"
        }
        Write-OK 'dotbrave -> applied'
    }
}
