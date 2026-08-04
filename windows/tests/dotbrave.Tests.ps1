Describe 'windows/modules/programs/dotbrave' {
    BeforeAll {
        $RepoRoot  = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ModPath   = Join-Path $RepoRoot 'windows\modules\programs\dotbrave\module.ps1'
        $ApplyPath = Join-Path $RepoRoot 'windows\apply.ps1'
        $ModText   = if (Test-Path $ModPath) { Get-Content -LiteralPath $ModPath -Raw } else { '' }
        $ApplyText = Get-Content -LiteralPath $ApplyPath -Raw

        # Anchor on the call operator, not on a phrase the module also uses in
        # prose. The module's comments legitimately contain "uvx", "--skip"
        # and "--unattended" (they explain, in prose, why the invocation looks
        # the way it does), and the throw message below the call repeats the
        # phrase "dotbrave apply" too -- filtering on any of those substrings
        # would catch commentary, not code. A line that starts with the call
        # operator `&` is, in this file, the invocation and only the
        # invocation.
        $InvokeLine = ($ModText -split "`r?`n" | Where-Object { $_ -match '^\s*&' }) -join "`n"
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

    It 'invokes dotbrave through uvx, not some other launcher' {
        # Guards the anchor itself: if the invocation line were ever deleted
        # while the $rc / throw scaffolding below it survived, $InvokeLine
        # would go empty and every assertion below would report PASS on a
        # module that no longer calls dotbrave at all. Fail loudly here first.
        $InvokeLine | Should Not BeNullOrEmpty
        $InvokeLine | Should Match 'uvx'
    }

    It 'passes --unattended so a failure cannot abort the run' {
        # Checked against the invocation line, not the whole file: the module
        # also carries a comment that explains, in prose, why PyPI is not
        # used, and that comment legitimately contains the substring
        # '--unattended'. Asserting against the full file text would keep
        # passing even if the flag were dropped from the real call, as long
        # as the comment survived.
        $InvokeLine | Should Not BeNullOrEmpty
        $InvokeLine | Should Match '--unattended'
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
