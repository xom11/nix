Describe 'windows programs.githooks' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        Import-Module (Join-Path $RepoRoot 'windows\lib\Logging.psm1') -Force
        $ModPath = Join-Path $RepoRoot 'windows\modules\programs\githooks\module.ps1'
        $Mod = & $ModPath
    }

    # This is the assertion that matters most. A module nobody runs is the exact
    # failure this repo keeps getting bitten by: a fence that is present, looks
    # installed, and never fires. apply.ps1 is the only thing that runs modules.
    It 'is registered in the apply.ps1 module list' {
        $apply = Get-Content (Join-Path $RepoRoot 'windows\apply.ps1') -Raw
        $apply | Should Match "'programs\.githooks'"
    }

    It 'ships an executable hook to point at' {
        $hook = Join-Path $RepoRoot '.githooks\pre-push'
        (Test-Path -LiteralPath $hook) | Should Be $true
        (Get-Content $hook -Raw).Length -gt 0 | Should Be $true
    }

    It 'sets core.hooksPath on a repo that does not have it' {
        $repo = Join-Path $TestDrive 'repo'
        New-Item -ItemType Directory -Path (Join-Path $repo '.githooks') -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $repo '.githooks\pre-push') -Value '#!/bin/sh' -Encoding UTF8
        git init -q $repo 2>&1 | Out-Null
        $global:LASTEXITCODE = 0

        & $Mod.Apply @{ RepoRoot = $repo } | Out-Null

        (git -C $repo config --local --get core.hooksPath) | Should Be (($repo -replace '\\', '/') + '/.githooks')
        $global:LASTEXITCODE = 0
    }

    # The trap this module exists to avoid: git resolves a relative core.hooksPath
    # against the current directory, not the repo root, so `git push` from a
    # subdirectory silently runs no hook at all.
    It 'writes an absolute path, never a relative one' {
        $repo = Join-Path $TestDrive 'repo2'
        New-Item -ItemType Directory -Path (Join-Path $repo '.githooks') -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $repo '.githooks\pre-push') -Value '#!/bin/sh' -Encoding UTF8
        git init -q $repo 2>&1 | Out-Null
        $global:LASTEXITCODE = 0

        & $Mod.Apply @{ RepoRoot = $repo } | Out-Null

        $value = git -C $repo config --local --get core.hooksPath
        [System.IO.Path]::IsPathRooted($value) | Should Be $true
        $global:LASTEXITCODE = 0
    }

    It 'is idempotent and leaves LASTEXITCODE clean' {
        $repo = Join-Path $TestDrive 'repo3'
        New-Item -ItemType Directory -Path (Join-Path $repo '.githooks') -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $repo '.githooks\pre-push') -Value '#!/bin/sh' -Encoding UTF8
        git init -q $repo 2>&1 | Out-Null
        $global:LASTEXITCODE = 0

        & $Mod.Apply @{ RepoRoot = $repo } | Out-Null
        $first = git -C $repo config --local --get core.hooksPath
        $global:LASTEXITCODE = 0

        & $Mod.Apply @{ RepoRoot = $repo } | Out-Null

        # `git config --get` exits 1 when a key is unset, and a stray non-zero
        # LASTEXITCODE survives the rest of the process -- it reddens a CI job that
        # had no failing test and dirties the exit-status segment of an interactive
        # prompt. Same trap Update-PwshSecrets already had to handle.
        $LASTEXITCODE | Should Be 0
        (git -C $repo config --local --get core.hooksPath) | Should Be $first
        $global:LASTEXITCODE = 0
    }

    It 'refuses to configure a repo with no hook to point at' {
        $repo = Join-Path $TestDrive 'repo4'
        New-Item -ItemType Directory -Path $repo -Force | Out-Null
        git init -q $repo 2>&1 | Out-Null
        $global:LASTEXITCODE = 0

        & $Mod.Apply @{ RepoRoot = $repo } | Out-Null

        (git -C $repo config --local --get core.hooksPath) | Should BeNullOrEmpty
        $global:LASTEXITCODE = 0
    }
}
