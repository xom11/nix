Describe 'windows services.vkey task shape' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Module    = Get-Content -Raw (Join-Path $RepoRoot 'windows\modules\services\vkey\module.ps1')
        $script:ApplyText = Get-Content -Raw (Join-Path $RepoRoot 'windows\apply.ps1')
        $script:LaunchKanata = Get-Content -Raw (Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\launch-kanata.ahk')
    }

    It 'is wired into apply.ps1' {
        $script:ApplyText | Should Match ([regex]::Escape("'services.vkey'"))
    }

    It 'runs before services.kanata' {
        # kanata's launcher blocks until VKey is ready, so fixing VKey's task first means the
        # very next module's task already benefits. Ordering here is documentation as much as
        # mechanism, but getting it backwards would read as if the two were unrelated.
        $v = $script:ApplyText.IndexOf("'services.vkey'")
        $k = $script:ApplyText.IndexOf("'services.kanata'")
        ($v -lt $k) | Should Be $true
    }

    It 'keeps VKey unelevated' {
        # An elevated VKey puts UIPI between it and tongue: PostMessage from a Medium-integrity
        # process is dropped and language switching stops working with no error anywhere. The
        # task shipped as RunLevel=Highest and was fixed by hand on 2026-07-30; this module
        # exists so that fix survives VKey rewriting its own task.
        $script:Module | Should Match 'RunLevel Limited'
        $script:Module | Should Not Match 'RunLevel Highest'
    }

    It 'strips the trigger delay' {
        # A flat PT5S on this task was what kept VKey off the CPU until explorer + 4643 ms, and
        # therefore what kept kanata off the keyboard until then too.
        $script:Module | Should Match '\$tr\.Delay\s*=\s*'''''
        $script:Module | Should Match 'Set-ScheduledTask'
    }

    It 'never creates the task, only corrects one VKey made' {
        # VKey owns the task's existence via `run_at_startup = true` in its config.toml. Two
        # writers for one object is how the RunLevel fix got silently reverted before.
        $script:Module | Should Not Match 'Register-ScheduledTask'
        $script:Module | Should Match 'VKey creates it on first run'
    }

    It 'is a no-op when the task is already correct' {
        # apply.ps1 runs whole; a module that rewrites a correct task on every run makes the
        # output unreadable and churns the task's history.
        $script:Module | Should Match 'Write-Skip'
    }

    It 'is only safe because the launcher waits on VKey rather than on a clock' {
        # Dropping VKey's delay without that wait would let kanata register its hook first and
        # invert the LIFO chain. The two changes have to stay together.
        $script:LaunchKanata | Should Match 'WaitForInputIdle'
        $script:Module | Should Match 'launch-kanata\.ahk waits on VKey'
    }
}
