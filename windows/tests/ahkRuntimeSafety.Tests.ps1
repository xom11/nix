Describe 'windows AutoHotkey runtime safety' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:AhkExe = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
        $script:SwitchLanguagePath = Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\switch-language.ahk'
        $script:WindowManagerPath = Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\window-manager.ahk'
        $script:SwitchLanguage = Get-Content -Raw $script:SwitchLanguagePath
        $script:WindowManager = Get-Content -Raw $script:WindowManagerPath
    }

    It 'does not crash when switching language for a missing target window' {
        $testScript = Join-Path $TestDrive 'switch-language-missing-target.ahk'
        @"
#Requires AutoHotkey v2.0
#SingleInstance Force
#Include $script:SwitchLanguagePath
SetInputLang(0x0409, "ahk_id 0")
ExitApp(0)
"@ | Set-Content -LiteralPath $testScript -Encoding UTF8

        $output = & $script:AhkExe /ErrorStdOut $testScript 2>&1 | Out-String

        $LASTEXITCODE | Should Be 0
        $output | Should Not Match '==>'
        $output | Should Not Match 'Too many parameters'
    }

    It 'pins language switching to the hwnd observed by the timer' {
        $script:SwitchLanguage | Should Match 'SetInputLang\(VN, activeHwnd\)'
        $script:SwitchLanguage | Should Match 'SetInputLang\(EN, activeHwnd\)'
        $script:SwitchLanguage | Should Match 'PostMessage\(0x0050, 0, langID, , "ahk_id " hwnd\)'
    }

    It 'keeps window snapping errors from surfacing as AutoHotkey dialogs' {
        $script:WindowManager | Should Match 'try\s*\{[\s\S]*WinRestore'
        $script:WindowManager | Should Match 'catch\s*\{[\s\S]*return'
    }
}
