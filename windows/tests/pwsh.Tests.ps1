Describe 'windows packages.pwsh module' {
    BeforeAll {
        $RepoRoot   = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ModulePath = Join-Path $RepoRoot 'windows\modules\packages\pwsh\module.ps1'
        $ModuleText = Get-Content -Raw -LiteralPath $ModulePath
        $WingetText = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\modules\packages\winget\module.ps1')
        $ApplyText  = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\apply.ps1')

        function Write-OK { param($Msg) }
        function Write-Skip { param($Msg) }
        function Write-Warn { param($Msg) }
        function Write-Info { param($Msg) }
        function Write-Fail { param($Msg) }

        # Shadow the real Appx cmdlets. Both code paths in the module end by trying to remove
        # the packaged PowerShell, and unmocked that would uninstall it for real on whichever
        # machine runs the suite.
        function Get-AppxPackage { param($Name, $ErrorAction) }
        function Remove-AppxPackage {
            param([Parameter(ValueFromPipeline)]$InputObject, $ErrorAction)
            process { }
        }
    }

    It 'takes PowerShell 7 from the GitHub MSI rather than from winget' {
        $ModuleText | Should Match ([regex]::Escape("Join-Path `$env:ProgramFiles 'PowerShell\7\pwsh.exe'"))
        $ModuleText | Should Match 'releases/latest'
        $ModuleText | Should Match 'msiexec'
        $ModuleText | Should Match 'ADD_PATH=1'
        $ModuleText | Should Not Match 'Install-WingetPackages'
    }

    It 'covers every architecture the release publishes an MSI for' {
        foreach ($arch in 'arm64', 'x64', 'x86') {
            $ModuleText | Should Match ("'{0}'" -f $arch)
        }
    }

    It 'keeps Microsoft.PowerShell out of the winget list, whose manifest is MSIX only' {
        $WingetText | Should Not Match "(?m)^\s*'Microsoft\.PowerShell'"
    }

    It 'is applied before services.sshd, which points DefaultShell at the MSI path' {
        $pwshIndex = $ApplyText.IndexOf("'packages.pwsh'")
        $sshdIndex = $ApplyText.IndexOf("'services.sshd'")
        ($pwshIndex -ge 0) | Should Be $true
        ($sshdIndex -ge 0) | Should Be $true
        ($pwshIndex -lt $sshdIndex) | Should Be $true
    }

    Context 'when the MSI build is already current' {
        It 'neither downloads nor runs msiexec' {
            Mock Test-Path { $true }
            Mock Get-Item { [pscustomobject]@{ VersionInfo = [pscustomobject]@{ ProductVersion = '7.6.4' } } }
            Mock Invoke-RestMethod { [pscustomobject]@{ tag_name = 'v7.6.4'; assets = @() } }
            Mock Invoke-WebRequest { }
            Mock Get-AppxPackage { $null }
            Mock Remove-AppxPackage { }
            Mock Start-Process { }
            Mock Write-Skip { }
            Mock Write-OK { }
            Mock Write-Warn { }

            $module = & $ModulePath
            & $module.Apply @{}

            Assert-MockCalled -CommandName Invoke-WebRequest -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-Process -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Write-Skip -Times 1 -Exactly -Scope It
        }
    }

    Context 'when a newer release exists' {
        It 'downloads the matching MSI and installs it' {
            Mock Test-Path { $true }
            Mock Get-Item { [pscustomobject]@{ VersionInfo = [pscustomobject]@{ ProductVersion = '7.6.0' } } }
            Mock Invoke-RestMethod {
                [pscustomobject]@{
                    tag_name = 'v7.6.4'
                    assets   = @(
                        [pscustomobject]@{ name = 'PowerShell-7.6.4-win-arm64.msi'; browser_download_url = 'https://example/arm64.msi' }
                        [pscustomobject]@{ name = 'PowerShell-7.6.4-win-x64.msi';   browser_download_url = 'https://example/x64.msi' }
                        [pscustomobject]@{ name = 'PowerShell-7.6.4-win-x86.msi';   browser_download_url = 'https://example/x86.msi' }
                    )
                }
            }
            Mock Invoke-WebRequest { }
            Mock Get-AppxPackage { $null }
            Mock Remove-AppxPackage { }
            Mock Start-Process { [pscustomobject]@{ ExitCode = 0 } }
            Mock Remove-Item { }
            Mock Write-Skip { }
            Mock Write-OK { }
            Mock Write-Info { }
            Mock Write-Fail { }
            Mock Write-Warn { }

            $module = & $ModulePath
            & $module.Apply @{}

            Assert-MockCalled -CommandName Invoke-WebRequest -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-Process -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Write-Skip -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Write-Fail -Times 0 -Exactly -Scope It
        }
    }
}
