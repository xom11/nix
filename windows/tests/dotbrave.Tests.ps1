Describe 'windows/modules/programs/dotbrave' {
    BeforeAll {
        $RepoRoot  = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ModPath   = Join-Path $RepoRoot 'windows\modules\programs\dotbrave\module.ps1'
        $ApplyPath = Join-Path $RepoRoot 'windows\apply.ps1'
        $ModText   = if (Test-Path $ModPath) { Get-Content -LiteralPath $ModPath -Raw } else { '' }
        $ApplyText = Get-Content -LiteralPath $ApplyPath -Raw

        # The whole file legitimately contains the string '--skip pwa' -- inside
        # a comment explaining why this module does NOT pass it. Matching the
        # comment would be a false FAIL, so isolate the actual invocation line
        # and check only that.
        $InvokeLine = ($ModText -split "`r?`n" | Where-Object { $_ -match 'dotbrave apply' }) -join "`n"
    }

    It 'ships a module file' {
        Test-Path $ModPath | Should Be $true
    }

    It 'is registered in apply.ps1' {
        $ApplyText | Should Match "(?m)^\s*'programs\.dotbrave'"
    }

    It 'returns a hashtable with Description and Apply' {
        $mod = & $ModPath
        $mod.Description | Should Not BeNullOrEmpty
        $mod.Apply | Should Not BeNullOrEmpty
    }

    It 'reads the shared brave.toml, not a Windows-only copy' {
        $ModText | Should Match 'dotfiles\\browser\\dotbrave\\brave\.toml'
    }

    It 'runs dotbrave from git, not from PyPI' {
        # PyPI is still on 0.2.5, which predates --unattended and --skip.
        $ModText | Should Match 'git\+https://github\.com/xom11/dotbrave'
    }

    It 'passes --unattended so a failure cannot abort the run' {
        $ModText | Should Match '--unattended'
    }

    It 'does NOT pass --skip pwa -- on Windows the CLI owns every table' {
        # Checked against the invocation line only, not the whole file: the
        # module also carries a comment that explains, in prose, why there is
        # no --skip pwa here, and that comment legitimately contains the
        # substring '--skip'. Asserting against the full file text would make
        # that explanation itself fail the test it is there to justify.
        $InvokeLine | Should Not BeNullOrEmpty
        $InvokeLine | Should Not Match '--skip'
    }

    It 'resets LASTEXITCODE so it cannot leak into the next module' {
        $ModText | Should Match '\$global:LASTEXITCODE\s*=\s*0'
    }
}
