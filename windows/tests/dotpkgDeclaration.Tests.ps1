Describe 'dotpkg declaration and lock' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:PkgTomlPath = Join-Path $RepoRoot 'home-manager\dotfiles\windows\dotpkg\pkg.toml'
        $script:PkgToml = Get-Content -Raw -LiteralPath $script:PkgTomlPath
        $script:PkgLockPath = Join-Path (Split-Path $script:PkgTomlPath) 'pkg.lock'
        $script:PkgLock = Get-Content -Raw -LiteralPath $script:PkgLockPath
        $script:LinksText = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\links.ps1')
    }

    # Three assertions died with windows/modules/packages/{scoop,winget}/module.ps1
    # on 2026-08-12: two that compared pkg.toml against those modules' package
    # lists, and one that pinned both parsers to a plausible size. They existed
    # only because the same list was written twice, in two languages, for two
    # tools. There is one list now, so there is nothing left to disagree.
    #
    # What replaced them is the third assertion below: the declaration and the
    # lock have to agree. That is a real invariant rather than a bookkeeping one --
    # `dotpkg apply` exits 2 on a declared package with no lock entry.

    It 'links neither file into the home directory' {
        # Nothing writable belongs behind a symlink into this repo. dotpkg
        # rewrites pkg.lock with File::create + fs::rename, and the rename
        # replaces a symlink with a regular file -- measured on a14 2026-08-12,
        # after which the repo stopped receiving pins and `git status` stayed
        # clean. packages.dotpkg passes --config and --lock at the committed
        # files instead.
        $script:LinksText | Should Not Match 'dotpkg\\pkg\.toml'
        $script:LinksText | Should Not Match 'dotpkg\\pkg\.lock'
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
        # Sanity floors, per backend. They exist only to stop a regex that has
        # silently stopped matching from reporting agreement -- a gate that parses
        # nothing passes everything.
        #
        # They are deliberately well under the real counts (25 scoop, 9 winget as
        # of 2026-08-12) so that ordinary edits do not touch them. The winget one
        # started at 10 and had to come down when five self-updating apps were
        # dropped from the declaration; a floor that tracks the list closely is a
        # floor that gets edited for the wrong reasons.
        $floors = @{ scoop = 15; winget = 5 }

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

            # A package declared `pin = "none"` is EXPECTED to have no lock
            # entry, and that is not a hole in this gate -- it is dotpkg's item 7
            # ("two sources of truth about permitted versions is how a tool
            # starts lying"): a declaration that pins nothing resolves to
            # nothing, so there is nothing to record. Requiring a lock line for
            # one would demand a fact that does not exist.
            #
            # Parsed from `[<backend>.opts]`, one id per line, so an entry that
            # pins something normally is unaffected and still has to be locked.
            $optsSection = [regex]::Match(
                $script:PkgToml,
                ('(?ms)^\[' + $backend + '\.opts\](?<body>.*?)(?=^\[|\z)')).Groups['body'].Value
            $unpinned = @(
                [regex]::Matches($optsSection, '(?m)^\s*"(?<n>[^"]+)"\s*=\s*\{[^}]*pin\s*=\s*"none"') |
                    ForEach-Object { $_.Groups['n'].Value }
            )
            $declared = @($declared | Where-Object { $unpinned -notcontains $_ })

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

            $declared.Count | Should BeGreaterThan $floors[$backend]
            $locked.Count   | Should BeGreaterThan $floors[$backend]

            $missing = @($declared | Where-Object { $locked -notcontains $_ })
            "$backend : " + ($missing -join ', ') | Should Be "$backend : "
        }
    }
}
