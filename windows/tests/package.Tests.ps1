Describe 'windows/lib/Package.psm1 native architecture detection' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        Import-Module (Join-Path $RepoRoot 'windows\lib\Package.psm1') -Force
    }

    It 'answers the machine architecture in Windows vocabulary, for callers that are not scoop' {
        # Get-NativeArchitecture is the single place the environment is read; scoop, the
        # PowerShell MSI and look each translate its answer into their own naming. It returns
        # Windows' own names rather than scoop's, so a caller cannot pick up '64bit' by accident
        # and hand it to a release-asset URL.
        Get-NativeArchitecture -ProcessArch 'ARM64' -NativeArch ''      | Should Be 'ARM64'
        Get-NativeArchitecture -ProcessArch 'AMD64' -NativeArch ''      | Should Be 'AMD64'
        # The case that matters: emulated x64 shell on an ARM64 machine.
        Get-NativeArchitecture -ProcessArch 'AMD64' -NativeArch 'ARM64' | Should Be 'ARM64'
        Get-NativeArchitecture -ProcessArch 'x86'   -NativeArch 'ARM64' | Should Be 'ARM64'
    }

    It 'leaves no module reading PROCESSOR_ARCHITECTURE behind the helper''s back' {
        # packages.pwsh and programs.look both used to read it directly. For look that only cost
        # a warning, but packages.pwsh picks the MSI: an apply from an emulated shell would have
        # installed an emulated machine-wide pwsh 7 -- the shell every later apply then runs on,
        # making the mistake self-sustaining.
        foreach ($rel in @(
            'windows\modules\packages\pwsh\module.ps1'
            'windows\modules\programs\look\module.ps1'
        )) {
            $text = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot $rel)
            # Matched with the $env: prefix so the comments explaining the trap still may name it.
            $text | Should Not Match '\$env:PROCESSOR_ARCHITECTURE'
            $text | Should Match 'Get-NativeArchitecture'
        }
    }
}

Describe 'the declared scoop list covers what nvim needs on Windows' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        # Reads pkg.toml, not the old scoop module: that module is gone, and the
        # declaration is now the only place the scoop list exists.
        $PkgToml       = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'home-manager\dotfiles\windows\dotpkg\pkg.toml')
        $TreesitterLua = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'home-manager\programs\nvim\lua\plugins\treesitter.lua')
    }

    It 'installs the tree-sitter CLI, because the nvim config builds parsers on startup' {
        # treesitter.lua calls install() for every parser missing from its ensure list, on
        # every launch. Building one shells out to `tree-sitter`. The nix hosts get that CLI
        # from home.packages in home-manager/programs/nvim; Windows runs no home-manager, it
        # only symlinks lua/ -- so a14 spent every launch downloading 31 parser tarballs and
        # printing 31 'ENOENT ... tree-sitter' failures.
        $TreesitterLua | Should Match 'nvim-treesitter'
        $TreesitterLua | Should Match 'install\(missing\)'
        $PkgToml       | Should Match '"tree-sitter"'
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
