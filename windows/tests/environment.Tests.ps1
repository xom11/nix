Describe 'windows/lib/Environment.psm1 native architecture detection' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        Import-Module (Join-Path $RepoRoot 'windows\lib\Environment.psm1') -Force
    }

    It 'answers the machine architecture in Windows vocabulary, not scoop''s' {
        # One place reads the environment; scoop, the PowerShell MSI and look each
        # translate. Returning Windows' names stops a caller picking up '64bit' and
        # handing it to a release-asset URL.
        Get-NativeArchitecture -ProcessArch 'ARM64' -NativeArch ''      | Should Be 'ARM64'
        Get-NativeArchitecture -ProcessArch 'AMD64' -NativeArch ''      | Should Be 'AMD64'
        # The case that matters: emulated x64 shell on an ARM64 machine.
        Get-NativeArchitecture -ProcessArch 'AMD64' -NativeArch 'ARM64' | Should Be 'ARM64'
        Get-NativeArchitecture -ProcessArch 'x86'   -NativeArch 'ARM64' | Should Be 'ARM64'
    }

    It 'leaves no module reading PROCESSOR_ARCHITECTURE behind the helper''s back' {
        # packages.pwsh picks the MSI: an apply from an emulated shell would install an
        # emulated machine-wide pwsh 7 -- the shell every later apply then runs on.
        foreach ($rel in @(
            'windows\modules\packages\pwsh\module.ps1'
            'windows\modules\programs\look\module.ps1'
        )) {
            $text = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot $rel)
            # With the $env: prefix, so comments explaining the trap may still name it.
            $text | Should Not Match '\$env:PROCESSOR_ARCHITECTURE'
            $text | Should Match 'Get-NativeArchitecture'
        }
    }
}

Describe 'windows/modules/packages/psmodules' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Text = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\modules\packages\psmodules\module.ps1')
    }

    It 'only prepares NuGet and PSGallery when a module is actually missing' {
        # Both calls measured ~3s together, paid on every run of a converged machine to
        # set up an install that never happened.
        $lookup   = $script:Text.IndexOf('Get-Module -ListAvailable -Name $m')
        $exit     = $script:Text.IndexOf('if (-not $missing) { return }')
        $provider = $script:Text.IndexOf('Get-PackageProvider -Name NuGet')
        $lookup   | Should Not Be -1
        $exit     | Should BeGreaterThan $lookup
        $provider | Should BeGreaterThan $exit
    }
}
