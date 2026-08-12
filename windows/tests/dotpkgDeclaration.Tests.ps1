Describe 'dotpkg pkg.toml agrees with the scoop module' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:ScoopModule = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\modules\packages\scoop\module.ps1')
        $script:WingetModule = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\modules\packages\winget\module.ps1')
        $script:PkgTomlPath = Join-Path $RepoRoot 'home-manager\dotfiles\windows\dotpkg\pkg.toml'
        $script:PkgToml = Get-Content -Raw -LiteralPath $script:PkgTomlPath
        $script:PkgLockPath = Join-Path (Split-Path $script:PkgTomlPath) 'pkg.lock'
        $script:PkgLock = Get-Content -Raw -LiteralPath $script:PkgLockPath
        $script:LinksText = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\links.ps1')

        # Packages the scoop module installs. Bucket-qualified entries such as
        # 'xom11/beckon' are reduced to the app name, which is what pkg.toml
        # carries -- the bucket is declared separately on both sides.
        $scoopBlock = [regex]::Match(
            $script:ScoopModule,
            '-Packages\s*@\((?<body>.*?)\n\s*\)\s*-KeepArchitecture',
            'Singleline').Groups['body'].Value
        $script:ModulePackages = @(
            [regex]::Matches($scoopBlock, "(?m)^\s*'(?<n>[^']+)'") |
                ForEach-Object { ($_.Groups['n'].Value -split '/')[-1] } |
                Sort-Object
        )

        # The [scoop] section of pkg.toml, and only that section: a later
        # [winget] table must not be read as more scoop packages.
        $scoopSection = [regex]::Match(
            $script:PkgToml,
            '(?ms)^\[scoop\](?<body>.*?)(?=^\[|\z)').Groups['body'].Value
        $tomlBlock = [regex]::Match(
            $scoopSection,
            '(?ms)^packages\s*=\s*\[(?<body>.*?)^\]').Groups['body'].Value
        $script:TomlPackages = @(
            [regex]::Matches($tomlBlock, '"(?<n>[^"]+)"') |
                ForEach-Object { $_.Groups['n'].Value } |
                Sort-Object
        )
    }

    # A gate that parses nothing passes everything. Both parsers are pinned to a
    # plausible size before anything is compared, so a regex that silently stops
    # matching cannot report agreement.
    It 'parses a plausible number of packages from both sides' {
        $script:ModulePackages.Count | Should BeGreaterThan 15
        $script:TomlPackages.Count | Should BeGreaterThan 15
    }

    It 'declares the same scoop packages in both places' {
        # Why this exists: these two lists describe the same machine and are
        # written twice, in two languages, for two tools. Measured 2026-08-12 --
        # 25 packages on each side, identical sets, zero difference in either
        # direction. They agree only because someone keeps them in sync by hand,
        # and nothing said so until this test.
        #
        # The fix for a red here is a decision, not a nudge: either the entry
        # belongs in both, or dotpkg and this module have stopped describing the
        # same machine and one of them should stop trying.
        $onlyInModule = @($script:ModulePackages | Where-Object { $script:TomlPackages -notcontains $_ })
        $onlyInToml = @($script:TomlPackages | Where-Object { $script:ModulePackages -notcontains $_ })

        $onlyInModule -join ', ' | Should Be ''
        $onlyInToml -join ', ' | Should Be ''
    }

    It 'links both the declaration and the lock into the home directory' {
        # Without the links a third copy exists: the repo's, and whatever is
        # actually sitting in the home directory. The gate would then be
        # comparing two files while the machine obeys a third.
        $script:LinksText | Should Match "dotfiles\.dotpkg"
        $script:LinksText | Should Match 'dotpkg\\pkg\.toml'
        $script:LinksText | Should Match 'dotpkg\\pkg\.lock'
    }

    It 'keeps state.json out of the repository but requires the lock in it' {
        # This used to forbid BOTH files, on the grounds that committing them
        # would publish one host's state as if it were the fleet's. That reason
        # holds for state.json, which records what dotpkg OWNS on one machine.
        # It does not hold for pkg.lock: bucket + commit + version describes no
        # particular machine, which is the same role flake.lock and
        # nvim-pack-lock.json already play here -- both committed.
        #
        # Committing it is also what lets apply.ps1 work on a fresh machine:
        # `dotpkg apply` exits 2 on a declared package with no lock entry.
        $dir = Split-Path $script:PkgTomlPath
        (Test-Path -LiteralPath (Join-Path $dir 'pkg.lock'))   | Should Be $true
        (Test-Path -LiteralPath (Join-Path $dir 'state.json')) | Should Be $false
    }

    It 'locks every package it declares, for both backends' {
        # The failure this catches: adding a package to pkg.toml and not running
        # `dotpkg update`. On a machine that already has the package nothing
        # looks wrong -- but a fresh one fails the whole packages module with
        # exit 2, and the cause is a file nobody edited.
        #
        # Reads TOML by regex only, so CI needs no dotpkg binary. dotpkg is not a
        # flake input and CI has none.
        foreach ($backend in 'scoop', 'winget') {
            $section = [regex]::Match(
                $script:PkgToml,
                ('(?ms)^\[' + $backend + '\](?<body>.*?)(?=^\[|\z)')).Groups['body'].Value
            $block = [regex]::Match(
                $section, '(?ms)^packages\s*=\s*\[(?<body>.*?)^\]').Groups['body'].Value
            $declared = @(
                [regex]::Matches($block, '"(?<n>[^"]+)"') |
                    ForEach-Object { $_.Groups['n'].Value } |
                    Sort-Object
            )

            # Lock table headers differ by backend, and the difference is easy to
            # miss: scoop names are bare ([scoop.actionlint]) while winget ids
            # carry dots and so are quoted ([winget."7zip.7zip"]). Measured on the
            # real file 2026-08-12. Trim the quotes or every winget id compares
            # unequal to its own declaration.
            $locked = @(
                [regex]::Matches($script:PkgLock, ('(?m)^\[' + $backend + '\.(?<n>[^\]]+)\]')) |
                    ForEach-Object { $_.Groups['n'].Value.Trim('"') } |
                    Sort-Object
            )

            # A gate that parses nothing passes everything.
            $declared.Count | Should BeGreaterThan 10
            $locked.Count   | Should BeGreaterThan 10

            $missing = @($declared | Where-Object { $locked -notcontains $_ })
            "$backend : " + ($missing -join ', ') | Should Be "$backend : "
        }
    }

    It 'declares the same winget ids as the module it replaces' {
        # Why this exists: during the migration both halves are still in the tree,
        # and the module is still the thing that installs. The moment pkg.toml
        # carries a different set, `dotpkg apply` and `apply.ps1` describe two
        # different machines and nothing says so.
        #
        # This is a migration scaffold, not a keeper -- it dies with the module.
        # It replaced an assertion that pkg.toml must have NO [winget] table,
        # which existed to make adding one a deliberate act. That act has now
        # been taken.
        $moduleIds = @(
            [regex]::Matches($script:WingetModule, "(?m)^\s*'(?<n>[^']+)'") |
                ForEach-Object { $_.Groups['n'].Value } |
                Sort-Object
        )

        # [winget] only, stopping at the next table header -- [winget.guard] is a
        # sub-table and must not be read as more package ids.
        $tomlSection = [regex]::Match(
            $script:PkgToml,
            '(?ms)^\[winget\](?<body>.*?)(?=^\[|\z)').Groups['body'].Value
        $tomlBlock = [regex]::Match(
            $tomlSection,
            '(?ms)^packages\s*=\s*\[(?<body>.*?)^\]').Groups['body'].Value
        $tomlIds = @(
            [regex]::Matches($tomlBlock, '"(?<n>[^"]+)"') |
                ForEach-Object { $_.Groups['n'].Value } |
                Sort-Object
        )

        # A gate that parses nothing passes everything.
        $moduleIds.Count | Should BeGreaterThan 10
        $tomlIds.Count   | Should BeGreaterThan 10

        @($moduleIds | Where-Object { $tomlIds -notcontains $_ }) -join ', ' | Should Be ''
        @($tomlIds | Where-Object { $moduleIds -notcontains $_ }) -join ', ' | Should Be ''
    }
}
