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
