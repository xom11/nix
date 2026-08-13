Describe 'windows/modules/packages/dotpkg module contract' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:ModulePath = Join-Path $RepoRoot 'windows\modules\packages\dotpkg\module.ps1'
        $script:ModuleText = if (Test-Path -LiteralPath $script:ModulePath) {
            Get-Content -Raw -LiteralPath $script:ModulePath
        } else { '' }

        # Code only. Assertions that match prose as if it were code have been
        # wrong five times in this integration -- twice silently green.
        $script:Code = (($script:ModuleText -split "`n") |
            Where-Object { $_ -notmatch '^\s*#' }) -join "`n"

        # The `dotpkg apply` call, whose flags span several lines.
        $script:ApplyCall = [regex]::Match(
            $script:Code, '(?ms)Invoke-Native dotpkg @\(.*?\)\)\.ExitCode').Value
    }

    It 'is a module hashtable with an Apply block' {
        (Test-Path -LiteralPath $script:ModulePath) | Should Be $true
        $script:Code | Should Match 'Description\s*='
        $script:Code | Should Match 'Apply\s*='
    }

    It 'bootstraps scoop, then dotpkg from scoop, before applying' {
        # dotpkg manages scoop but does not install it, and cannot install itself.
        foreach ($step in 'Install-Scoop', 'xom11/dotpkg') {
            $at = $script:Code.IndexOf($step)
            $at | Should Not Be -1
            $at | Should BeLessThan $script:Code.IndexOf('Invoke-Native dotpkg @(')
        }
    }

    It 'never fetches the binary itself' {
        # scoop already does the hash check, the arch pick and the bucket pin.
        foreach ($bad in 'Invoke-WebRequest', 'Invoke-RestMethod', 'curl') {
            $script:Code | Should Not Match $bad
        }
    }

    It 'gates on a dotpkg new enough to read pkg.toml' {
        # 0.1.0 rejects [winget.opts] outright, and an older copy earlier in PATH
        # shadows the scoop shim. Version comparison, not string: '0.10.0' -lt
        # '0.2.0' is true for strings.
        $script:Code | Should Match "\[version\]'0\.2\.0'"
        $script:Code | Should Match '\[version\]\$Matches\[1\]'
    }

    It 'reads the committed files, not links in the home directory' {
        $script:ApplyCall | Should Match '--config'
        $script:ApplyCall | Should Match '--lock'
        $script:Code      | Should Match '\$Ctx\.RepoRoot'
        $script:Code      | Should Not Match '\$config = Join-Path \$env:USERPROFILE'
    }

    It 'passes the flags a fresh machine needs, and never prunes' {
        $script:ApplyCall | Should Match 'apply'
        foreach ($flag in '--yes', '--keep-going', '--clone-missing-buckets') {
            $script:ApplyCall | Should Match $flag
        }
        $script:Code | Should Not Match '--allow-prune'
    }

    It 'runs native commands with ErrorActionPreference off Stop' {
        # apply.ps1 sets Stop; this scriptblock inherits it; Stop turns dotpkg's
        # stderr warnings into a terminating error before any exit code is read.
        $helper = [regex]::Match($script:Code, '(?ms)function Invoke-Native.*?\r?\n        \}').Value
        $helper | Should Match "ErrorActionPreference = 'Continue'"
        $helper | Should Match 'finally'
        $helper | Should Match '\$global:LASTEXITCODE\s*=\s*0'

        # And nothing calls dotpkg or scoop outside it.
        $script:Code | Should Not Match '(?m)^\s*(dotpkg|scoop) '
    }

    It 'maps every exit code, and only 0 and 3 are success' {
        # 0 done · 3 only a running app left · 1 needs a person · 2+ refused.
        $sw = [regex]::Match($script:Code, '(?ms)switch \(\$rc\) \{.*?\r?\n        \}').Value
        $sw | Should Match '(?m)^\s*0\s*\{[^}]*Write-OK'
        $sw | Should Match '(?m)^\s*3\s*\{[^}]*Write-OK'
        $sw | Should Match '(?m)^\s*1\s*\{[^}]*throw'
        $sw | Should Match '(?m)^\s*default\s*\{[^}]*throw'
        $sw | Should Not Match 'Write-Warn'
    }
}
