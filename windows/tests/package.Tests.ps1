Describe 'windows/lib/Package.psm1 winget install detection' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $LibPath  = Join-Path $RepoRoot 'windows\lib\Package.psm1'
        Import-Module $LibPath -Force
        $LibText = Get-Content -LiteralPath $LibPath -Raw

        # Build a table shaped like winget's: fixed-width Name and Id columns. Padding the
        # columns here rather than pasting real output keeps the header offsets explicit --
        # they are exactly what the parser reads positions from.
        function New-WingetTable {
            param([hashtable[]]$Rows)
            $nameWidth = 40
            $idWidth   = 40
            $lines = @(
                ('Name'.PadRight($nameWidth) + 'Id'.PadRight($idWidth) + 'Version')
                ('-' * ($nameWidth + $idWidth + 10))
            )
            foreach ($row in $Rows) {
                $lines += ($row.Name.PadRight($nameWidth) + $row.Id.PadRight($idWidth) + $row.Version)
            }
            return $lines
        }
    }

    It 'reads whole ids out of the Id column' {
        $ids = ConvertFrom-WingetList -Lines (New-WingetTable @(
            @{ Name = '7-Zip 26.01 (x64 edition)'; Id = '7zip.7zip';                    Version = '26.01' }
            @{ Name = 'Visual Studio Code';        Id = 'Microsoft.VisualStudioCode';   Version = '1.99' }
            @{ Name = 'JetBrains Mono';            Id = 'DEVCOM.JetBrainsMonoNerdFont'; Version = '3.4.0' }
        ))

        $ids.Contains('7zip.7zip') | Should Be $true
        $ids.Contains('Microsoft.VisualStudioCode') | Should Be $true
        $ids.Contains('DEVCOM.JetBrainsMonoNerdFont') | Should Be $true
        $ids.Count | Should Be 3
    }

    It 'does not let a longer id satisfy a shorter one' {
        # The bug that pushed this code to one-query-per-package in the first place: a
        # substring match reports Microsoft.PowerShell as present when only the Preview
        # channel is installed.
        $ids = ConvertFrom-WingetList -Lines (New-WingetTable @(
            @{ Name = 'PowerShell Preview'; Id = 'Microsoft.PowerShell.Preview'; Version = '7.7.0' }
        ))

        $ids.Contains('Microsoft.PowerShell.Preview') | Should Be $true
        $ids.Contains('Microsoft.PowerShell') | Should Be $false
    }

    It 'drops a truncated id rather than reporting it under a cut-short name' {
        # winget shortens a long id to the console width and marks it with U+2026. Keeping
        # that row would answer questions about an id nobody asked for.
        $ellipsis = [char]0x2026
        $ids = ConvertFrom-WingetList -Lines (New-WingetTable @(
            @{ Name = 'Some App'; Id = "Microsoft.Win$ellipsis"; Version = '1.0' }
            @{ Name = 'Good App'; Id = 'gerardog.gsudo';         Version = '2.6' }
        ))

        $ids.Contains('gerardog.gsudo') | Should Be $true
        $ids.Count | Should Be 1
    }

    It 'returns an empty set when there is no table to read' {
        # A localised Windows, an error dump, or no output at all. Empty means "cannot say",
        # which sends every id to the exact query -- it must never mean "not installed".
        (ConvertFrom-WingetList -Lines @('winget: something went wrong')).Count | Should Be 0
        (ConvertFrom-WingetList -Lines @()).Count | Should Be 0
        (ConvertFrom-WingetList -Lines $null).Count | Should Be 0
    }

    It 'hands back a set, not an unrolled array' {
        # PowerShell enumerates IEnumerable returns by default, which would turn the set into
        # a string[] and take .Contains() -- the exact-match guarantee -- with it.
        $ids = ConvertFrom-WingetList -Lines (New-WingetTable @(
            @{ Name = 'App'; Id = 'some.app'; Version = '1.0' }
        ))
        $ids.GetType().Name | Should Be 'HashSet`1'
    }

    It 'checks the bulk table first and only then pays for a per-package query' {
        $LibText | Should Match 'Get-WingetInstalledIds'
        $bulkAt     = $LibText.IndexOf('$installedIds = Get-WingetInstalledIds')
        $fallbackAt = $LibText.IndexOf('$present = Test-WingetPackageInstalled -Id $id')
        ($bulkAt -ge 0 -and $fallbackAt -gt $bulkAt) | Should Be $true
    }
}

Describe 'windows/lib/Package.psm1 scoop architecture' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $LibPath  = Join-Path $RepoRoot 'windows\lib\Package.psm1'
        Import-Module $LibPath -Force
        $LibText  = Get-Content -LiteralPath $LibPath -Raw
        $ScoopModuleText = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\modules\packages\scoop\module.ps1')
    }

    It 'reads the machine architecture, not the architecture of the process asking' {
        # a14 shipped a whole toolchain built for the wrong CPU because scoop was left at its
        # 64bit default on an ARM64 laptop. PROCESSOR_ARCHITECTURE describes the *process*, so
        # an emulated PowerShell would answer AMD64 and quietly reproduce that mistake --
        # PROCESSOR_ARCHITEW6432 is the only variable that carries the real machine.
        Get-ScoopNativeArchitecture -ProcessArch 'ARM64' -NativeArch ''      | Should Be 'arm64'
        Get-ScoopNativeArchitecture -ProcessArch 'AMD64' -NativeArch 'ARM64' | Should Be 'arm64'
        Get-ScoopNativeArchitecture -ProcessArch 'x86'   -NativeArch 'ARM64' | Should Be 'arm64'
        Get-ScoopNativeArchitecture -ProcessArch 'AMD64' -NativeArch ''      | Should Be '64bit'
        Get-ScoopNativeArchitecture -ProcessArch 'x86'   -NativeArch ''      | Should Be '32bit'
    }

    It 'falls back to 64bit rather than guessing on an architecture it does not know' {
        Get-ScoopNativeArchitecture -ProcessArch 'SOMETHING_NEW' -NativeArch '' | Should Be '64bit'
        Get-ScoopNativeArchitecture -ProcessArch '' -NativeArch ''              | Should Be '64bit'
    }

    It 'flags an app installed for the wrong architecture when the manifest offers the right one' {
        Test-ScoopArchDrift -NativeArch 'arm64' -InstalledArch '64bit' -ManifestArchs @('64bit','arm64') | Should Be $true
    }

    It 'leaves an app alone when the manifest has no build for this machine' {
        # stylua/age/shfmt ship x64 only. Reinstalling them changes nothing and costs a
        # download, and an uninstall that is not followed by a working install loses the tool.
        Test-ScoopArchDrift -NativeArch 'arm64' -InstalledArch '64bit' -ManifestArchs @('64bit')        | Should Be $false
        Test-ScoopArchDrift -NativeArch 'arm64' -InstalledArch '64bit' -ManifestArchs @('64bit','32bit') | Should Be $false
        Test-ScoopArchDrift -NativeArch 'arm64' -InstalledArch '64bit' -ManifestArchs @()               | Should Be $false
        Test-ScoopArchDrift -NativeArch 'arm64' -InstalledArch '64bit' -ManifestArchs $null             | Should Be $false
    }

    It 'says nothing to do when the app is already on this architecture' {
        Test-ScoopArchDrift -NativeArch 'arm64' -InstalledArch 'arm64' -ManifestArchs @('64bit','arm64') | Should Be $false
        Test-ScoopArchDrift -NativeArch '64bit' -InstalledArch '64bit' -ManifestArchs @('64bit','arm64') | Should Be $false
    }

    It 'does not churn an install whose architecture was never recorded' {
        # Apps installed by an older scoop have no install.json. "Unknown" must not read as
        # "wrong", or every apply would uninstall and refetch them.
        Test-ScoopArchDrift -NativeArch 'arm64' -InstalledArch ''    -ManifestArchs @('64bit','arm64') | Should Be $false
        Test-ScoopArchDrift -NativeArch 'arm64' -InstalledArch $null -ManifestArchs @('64bit','arm64') | Should Be $false
        Test-ScoopArchDrift -NativeArch ''      -InstalledArch '64bit' -ManifestArchs @('arm64')       | Should Be $false
    }

    It 'reinstalls in place of the plain skip, because scoop cannot change architecture in place' {
        # The old code skipped anything already present, so setting default_architecture would
        # only ever have fixed a machine nobody had installed on yet.
        $LibText | Should Match 'Test-ScoopArchDrift'
        $LibText | Should Match 'scoop uninstall'
    }

    It 'checks the app came back after an uninstall+install' {
        # This is not hypothetical: reinstalling rustup on a14 uninstalled it and then failed
        # to install, and the silence left the machine with no rustup at all.
        $LibText | Should Match 'Test-ScoopAppPresent'
        $LibText | Should Match 'Write-Fail'
    }

    It 'installs a forced architecture on a machine that never had the app' {
        # A bare pin only ever held an EXISTING install still. First install fell through to
        # the plain `scoop install`, took the machine's native architecture, and was pinned to
        # it from then on -- so on a freshly built arm64 box the pin guaranteed exactly the
        # build it existed to avoid, and reported success doing it. kanata is the case that
        # matters: that build has no kanata_windows_tty_winIOv2_x64.exe, so the machine comes
        # up with no keyboard and a watchdog too quiet to say so.
        $LibText | Should Match 'scoop install \$pkg --arch \$pinArch'

        # The forced install must sit in the not-installed branch, i.e. before the skip that
        # handles bare pins -- that ordering is the whole fix.
        $forcedAt = $LibText.IndexOf('scoop install $pkg --arch $pinArch')
        $skipAt   = $LibText.IndexOf('(architecture pinned)')
        ($forcedAt -ge 0 -and $skipAt -gt $forcedAt) | Should Be $true
    }

    It 'pins the packages an architecture swap would break' {
        # kanata: launch-kanata.ahk and its watchdog resolve one exact filename,
        #   kanata_windows_tty_winIOv2_x64.exe, which the arm64 build does not carry -- the
        #   swap takes the keyboard down and the watchdog launches quiet, so nothing says why.
        # rustup: the scoop package is only the bootstrapper, and its post_install stays
        #   resident holding a lock on the file the next install must write.
        # python: 32-bit, with native wheels built against it.
        # Read the -KeepArchitecture block on its own. All three names also appear in the
        # install list above it, so matching the whole file would still pass with the pin
        # deleted -- which is the only thing this test exists to catch.
        $keepAt = $ScoopModuleText.IndexOf('-KeepArchitecture')
        ($keepAt -ge 0) | Should Be $true
        $keepBlock = $ScoopModuleText.Substring($keepAt)

        # kanata carries '=64bit' rather than a bare name, and that is load-bearing: its
        # manifest does offer arm64, so on a freshly built arm64 machine the bare form fell
        # through to the plain install and fetched the build that has no
        # kanata_windows_tty_winIOv2_x64.exe -- no keyboard, on first boot, with the pin
        # sitting right there reading as though it had handled it.
        $keepBlock | Should Match "(?m)^\s*'kanata=64bit'\s*$"
        $keepBlock | Should Match "(?m)^\s*'rustup'\s*$"
        $keepBlock | Should Match "(?m)^\s*'python'\s*$"
        $LibText   | Should Match '\$KeepArchitecture'
    }

    It 'refuses to uninstall an app whose own processes are alive' {
        # scoop declines anyway, but declining mid-sweep after the uninstall has already run
        # is the state that loses the tool.
        $LibText | Should Match 'Get-ScoopAppProcess'
        $checkAt     = $LibText.IndexOf('$running = @(Get-ScoopAppProcess')
        $uninstallAt = $LibText.IndexOf('scoop uninstall $name')
        ($checkAt -ge 0 -and $uninstallAt -gt $checkAt) | Should Be $true
    }

    It 'sets the scoop default before installing anything' {
        $setAt     = $LibText.IndexOf('Set-ScoopArchitectureDefault')
        $installAt = $LibText.IndexOf('Write-Info "scoop install $pkg"')
        ($setAt -ge 0 -and $installAt -gt $setAt) | Should Be $true
    }
}

Describe 'windows scoop list covers what nvim needs on Windows' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ScoopModuleText = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\modules\packages\scoop\module.ps1')
        $TreesitterLua   = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'home-manager\programs\nvim\lua\plugins\treesitter.lua')
    }

    It 'installs the tree-sitter CLI, because the nvim config builds parsers on startup' {
        # treesitter.lua calls install() for every parser missing from its ensure list, on
        # every launch. Building one shells out to `tree-sitter`. The nix hosts get that CLI
        # from home.packages in home-manager/programs/nvim; Windows runs no home-manager, it
        # only symlinks lua/ -- so a14 spent every launch downloading 31 parser tarballs and
        # printing 31 'ENOENT ... tree-sitter' failures.
        $TreesitterLua   | Should Match 'nvim-treesitter'
        $TreesitterLua   | Should Match 'install\(missing\)'
        $ScoopModuleText | Should Match "(?m)^\s*'tree-sitter'\s*$"
    }
}

Describe 'windows/lib/Package.psm1 PowerShell module installs' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $LibText  = Get-Content -LiteralPath (Join-Path $RepoRoot 'windows\lib\Package.psm1') -Raw
    }

    It 'only prepares NuGet and PSGallery when a module is actually missing' {
        # Both calls measured ~3s together and were paid on every run to set up an install
        # that a converged machine never performs.
        $lookupAt   = $LibText.IndexOf('Get-Module -ListAvailable -Name $m')
        $earlyExit  = $LibText.IndexOf('if (-not $missing) { return }')
        $providerAt = $LibText.IndexOf('Get-PackageProvider -Name NuGet')
        ($lookupAt -ge 0 -and $earlyExit -gt $lookupAt -and $providerAt -gt $earlyExit) | Should Be $true
    }
}
