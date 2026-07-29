Describe 'windows New-IdempotentSymlink' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        Import-Module (Join-Path $RepoRoot 'windows\lib\Logging.psm1') -Force
        Import-Module (Join-Path $RepoRoot 'windows\lib\Symlink.psm1') -Force
    }

    It 'reports failure and touches nothing when the source is missing' {
        $target = Join-Path $TestDrive 'no-source-target.txt'
        New-IdempotentSymlink -Source (Join-Path $TestDrive 'does-not-exist') -Target $target |
            Should Be $false
        (Test-Path $target) | Should Be $false
    }

    It 'moves a real file out of the way instead of deleting it' {
        $source = Join-Path $TestDrive 'real-source.txt'
        $target = Join-Path $TestDrive 'real-target.txt'
        Set-Content -LiteralPath $source -Value 'from the repo' -Encoding UTF8
        Set-Content -LiteralPath $target -Value 'precious user data' -Encoding UTF8

        New-IdempotentSymlink -Source $source -Target $target | Out-Null

        # The point of the test: the original content still exists somewhere. An earlier
        # version ran Remove-Item -Force -Recurse over whatever was in the way.
        (Test-Path "$target.bak") | Should Be $true
        (Get-Content "$target.bak" -Raw).Trim() | Should Be 'precious user data'
    }

    It 'moves a real directory aside rather than recursing over it' {
        $source = Join-Path $TestDrive 'dir-source'
        $target = Join-Path $TestDrive 'dir-target'
        New-Item -ItemType Directory -Path $source | Out-Null
        New-Item -ItemType Directory -Path $target | Out-Null
        Set-Content -LiteralPath (Join-Path $target 'keepme.txt') -Value 'do not lose me' -Encoding UTF8

        New-IdempotentSymlink -Source $source -Target $target | Out-Null

        (Test-Path (Join-Path "$target.bak" 'keepme.txt')) | Should Be $true
        (Get-Content (Join-Path "$target.bak" 'keepme.txt') -Raw).Trim() | Should Be 'do not lose me'
    }

    It 'does not collide when something has already been moved aside once' {
        $source = Join-Path $TestDrive 'collide-source.txt'
        $target = Join-Path $TestDrive 'collide-target.txt'
        Set-Content -LiteralPath $source -Value 'from the repo' -Encoding UTF8
        Set-Content -LiteralPath "$target.bak" -Value 'older backup' -Encoding UTF8
        Set-Content -LiteralPath $target -Value 'newer data' -Encoding UTF8

        New-IdempotentSymlink -Source $source -Target $target | Out-Null

        (Get-Content "$target.bak" -Raw).Trim()  | Should Be 'older backup'
        (Get-Content "$target.bak1" -Raw).Trim() | Should Be 'newer data'
    }
}
