Describe 'dotpkg declaration and lock' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:PkgTomlPath = Join-Path $RepoRoot 'home-manager\dotfiles\windows\dotpkg\pkg.toml'
        $script:PkgToml = Get-Content -Raw -LiteralPath $script:PkgTomlPath
        $script:PkgLock = Get-Content -Raw -LiteralPath (Join-Path (Split-Path $script:PkgTomlPath) 'pkg.lock')
        $script:LinksText = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\links.ps1')

        function Get-TomlSection {
            param([string]$Name)
            [regex]::Match($script:PkgToml,
                ('(?ms)^\[' + [regex]::Escape($Name) + '\](?<b>.*?)(?=^\[|\z)')).Groups['b'].Value
        }
        # Comment lines out before quotes are read: prose in the array quotes
        # things, and a comment was once parsed as two more declared packages.
        function Get-QuotedNames {
            param([string]$Text)
            $code = (($Text -split "`n") | Where-Object { $_ -notmatch '^\s*#' }) -join "`n"
            @([regex]::Matches($code, '"(?<n>[^"]+)"') | ForEach-Object { $_.Groups['n'].Value })
        }
    }

    It 'links neither file into the home directory' {
        # dotpkg rewrites the lock through fs::rename, which replaces a symlink
        # with a regular file -- after which the repo stops receiving pins,
        # `git status` clean throughout.
        $script:LinksText | Should Not Match 'dotpkg\\pkg\.toml'
        $script:LinksText | Should Not Match 'dotpkg\\pkg\.lock'
    }

    It 'keeps state.json out of the repository but requires the lock in it' {
        # state.json records what dotpkg owns on ONE machine; the lock is
        # bucket + commit + version and names none, like flake.lock.
        $dir = Split-Path $script:PkgTomlPath
        (Test-Path -LiteralPath (Join-Path $dir 'pkg.lock'))   | Should Be $true
        (Test-Path -LiteralPath (Join-Path $dir 'state.json')) | Should Be $false
    }

    It 'declares the tree-sitter CLI, which the nvim config shells out to on startup' {
        # treesitter.lua calls install() for every parser missing from its ensure list,
        # on every launch. The nix hosts get the CLI from home.packages; Windows runs no
        # home-manager and only symlinks lua/, so without this a14 spent every launch
        # downloading 31 parser tarballs and printing 31 ENOENT failures.
        $lua = Get-Content -Raw -LiteralPath (Join-Path (Split-Path $script:PkgTomlPath) '..\..\..\programs\nvim\lua\plugins\treesitter.lua')
        $lua            | Should Match 'nvim-treesitter'
        $lua            | Should Match 'install\(missing\)'
        $script:PkgToml | Should Match '"tree-sitter"'
    }

    It 'locks every package it declares, for both backends' {
        # Catches a package added to pkg.toml without `dotpkg update`: harmless on
        # a machine that already has it, exit 2 on a fresh one. Regex only, so CI
        # needs no dotpkg binary.
        #
        # Floors only stop a regex that stopped matching from reporting agreement;
        # kept well under the real counts so ordinary edits never touch them.
        $floors = @{ scoop = 15; winget = 5 }

        foreach ($backend in 'scoop', 'winget') {
            $block = [regex]::Match((Get-TomlSection $backend),
                '(?ms)^packages\s*=\s*\[(?<b>.*?)^\]').Groups['b'].Value
            $declared = Get-QuotedNames $block | Sort-Object

            # `pin = "none"` resolves to nothing, so it records nothing.
            $unpinned = @(
                [regex]::Matches((Get-TomlSection "$backend.opts"),
                    '(?m)^\s*"(?<n>[^"]+)"\s*=\s*\{[^}]*pin\s*=\s*"none"') |
                    ForEach-Object { $_.Groups['n'].Value }
            )
            $declared = @($declared | Where-Object { $unpinned -notcontains $_ })

            # scoop names are bare ([scoop.age]); winget ids carry dots and so are
            # quoted ([winget."7zip.7zip"]).
            $locked = @(
                [regex]::Matches($script:PkgLock, ('(?m)^\[' + $backend + '\.(?<n>[^\]]+)\]')) |
                    ForEach-Object { $_.Groups['n'].Value.Trim('"') } |
                    Sort-Object
            )

            $declared.Count | Should BeGreaterThan $floors[$backend]
            $locked.Count   | Should BeGreaterThan $floors[$backend]

            $missing = @($declared | Where-Object { $locked -notcontains $_ })
            "$backend : " + ($missing -join ', ') | Should Be "$backend : "
        }
    }
}
