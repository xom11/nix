# parse.ahk phai dump ra dung apps.expected.tsv, giong parse.lua va dump.nix.
# Ba parser cung dong y voi mot file tuc la dong y voi nhau.
#
# Pester 3.4.0 -- cu phap `Should Be`, khong phai `Should -Be`.
Describe 'configs/shortcuts parse.ahk' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:ParsePath = Join-Path $RepoRoot 'configs\shortcuts\parse.ahk'
        $script:GoldenPath = Join-Path $RepoRoot 'configs\shortcuts\apps.expected.tsv'
        $script:Ahk = $env:AHK_EXE
    }

    It 'co mat trong repo' {
        Test-Path $script:ParsePath | Should Be $true
    }

    It 'dump khop apps.expected.tsv cho ca bon target' {
        if (-not $script:Ahk -or -not (Test-Path $script:Ahk)) {
            # Tren CI thi PHAI co AHK -- neu buoc cai that bai lang le thi test
            # nay se inconclusive mai mai va CI xanh ma khong chung minh gi.
            # Duoi may cua nguoi dung khong co AHK thi bo qua la hop ly.
            if ($env:CI) { throw 'AHK_EXE khong tro toi AutoHotkey v2 tren CI' }
            Set-TestInconclusive -Message 'AHK_EXE chua tro toi AutoHotkey v2'
            return
        }

        $out = Join-Path $env:TEMP 'shortcuts-dump.tsv'
        if (Test-Path $out) { Remove-Item $out }

        foreach ($t in @('gnome', 'macos', 'sway', 'windows')) {
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = $script:Ahk
            $psi.Arguments = "`"$($script:ParsePath)`" --dump $t"
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.UseShellExecute = $false
            $p = [System.Diagnostics.Process]::Start($psi)
            $stdout = $p.StandardOutput.ReadToEnd()
            $stderr = $p.StandardError.ReadToEnd()
            $p.WaitForExit()

            if ($p.ExitCode -ne 0) {
                throw "parse.ahk --dump $t exit $($p.ExitCode): $stderr"
            }
            [IO.File]::AppendAllText($out, $stdout)
        }

        $got = (Get-Content -Raw $out) -replace "`r`n", "`n"
        $want = (Get-Content -Raw $script:GoldenPath) -replace "`r`n", "`n"
        $got | Should Be $want
    }
}
