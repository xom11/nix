Describe 'windows AutoHotkey app launcher' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:LaunchAppPath = Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\launch-app.ahk'
        $script:LaunchApp = Get-Content -Raw $script:LaunchAppPath
    }

    It 'delegates app launch directly to beckon without an elevation workaround' {
        $script:LaunchApp | Should Match 'Beckon\(name\)[\s\S]*RunWait\(''beckon\.exe'
        $script:LaunchApp | Should Not Match 'ShellExecute'
        $script:LaunchApp | Should Not Match 'RunAsUser'
    }
}
