Describe 'windows AutoHotkey privilege model' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:MainAhk = Get-Content -Raw (Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\main.ahk')
        $script:AhkTaskModule = Get-Content -Raw (Join-Path $RepoRoot 'windows\modules\services\ahk\module.ps1')
        $script:ApplyText = Get-Content -Raw (Join-Path $RepoRoot 'windows\apply.ps1')
        $script:KanataTaskModulePath = Join-Path $RepoRoot 'windows\modules\services\kanata\module.ps1'
    }

    It 'does not elevate the whole AutoHotkey process' {
        $script:MainAhk | Should Not Match 'A_IsAdmin'
        $script:MainAhk | Should Not Match '\*RunAs'
        $script:MainAhk | Should Not Match '#Include launch-kanata\.ahk'
    }

    It 'runs the AutoHotkey scheduled task as a limited user process' {
        $script:AhkTaskModule | Should Match 'RunLevel Limited'
        $script:AhkTaskModule | Should Not Match 'RunLevel Highest'
        $script:AhkTaskModule | Should Not Match 'Run as Admin'
    }

    It 'keeps Kanata isolated in its own elevated scheduled task' {
        Test-Path -LiteralPath $script:KanataTaskModulePath | Should Be $true
        $kanataTaskModule = Get-Content -Raw $script:KanataTaskModulePath

        $script:ApplyText | Should Match ([regex]::Escape("'services.kanata'"))
        $kanataTaskModule | Should Match 'kanata'
        $kanataTaskModule | Should Match 'RunLevel Highest'
        $kanataTaskModule | Should Match 'kanata_windows\.kbd'
    }
}
