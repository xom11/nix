Describe 'windows AutoHotkey app launcher' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:LaunchAppPath = Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\launch-app.ahk'
        $script:LaunchApp = Get-Content -Raw $script:LaunchAppPath
    }

    It 'delegates app launch directly to beckon without an elevation workaround' {
        $script:LaunchApp | Should Match 'RunWait\(''beckon\.exe'
        $script:LaunchApp | Should Not Match 'ShellExecute'
        $script:LaunchApp | Should Not Match 'RunAsUser'
    }

    It 'khong con bang phim cung trong file' {
        # Bang phim phai den tu configs/shortcuts/apps.toml. Mot dong `^#!x::`
        # nghia la ai do chep lai binding vao day va no se lech ngay lap tuc.
        $script:LaunchApp | Should Match 'ShortcutsParse'
        $script:LaunchApp | Should Not Match '\^#!\S*::'
    }

    It 'bao loi khi beckon that bai thay vi nuot' {
        # Ban cu la `try RunWait(...)`: try nuot sach, exit code bi bo, nen
        # beckon khong resolve duoc thi Windows im hoan toan con mac hien alert.
        $script:LaunchApp | Should Match 'TrayTip'
        $script:LaunchApp | Should Match 'ExitCode|code != 0|code !== 0'
    }

    It 'khong con phu thuoc which-key' {
        $script:LaunchApp | Should Not Match 'WhichKey'
        $whichKey = Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\lib\which-key.ahk'
        Test-Path $whichKey | Should Be $false
    }
}
