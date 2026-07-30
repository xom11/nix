Describe 'windows services.sshd module' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ModulePath = Join-Path $RepoRoot 'windows\modules\services\sshd\module.ps1'

        function Write-OK { param($Msg) }
        function Write-Skip { param($Msg) }
        function Write-Info { param($Msg) }
        function Write-Warn { param($Msg) }
        function Get-WindowsCapability { param([switch]$Online, $Name) }
        function Add-WindowsCapability { param([switch]$Online, $Name) }
        function Get-Service { param($Name) }
        function Set-Service { param($Name, $StartupType) }
        function Start-Service { param($Name) }
        function Stop-Service { param($Name, [switch]$Force) }
        function Get-NetFirewallRule { param($Name, $ErrorAction) }
        function New-NetFirewallRule {
            param($Name, $DisplayName, $Enabled, $Direction, $Protocol, $Action, $LocalPort)
        }
        function Set-NetFirewallRule { param($Name, $Enabled, $Direction, $Action) }
        function Get-NetFirewallPortFilter {
            param([Parameter(ValueFromPipeline)]$InputObject)
            process { }
        }
        function Set-NetFirewallPortFilter {
            param([Parameter(ValueFromPipeline)]$InputObject, $Protocol, $LocalPort)
            process { }
        }

        $PwshMsiPath = Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'
        # The DefaultShell block is guarded by this file existing, so the expected number of
        # registry writes depends on the machine the suite runs on. Compute it rather than
        # hardcoding, otherwise the suite only passes where PowerShell 7 MSI is installed.
        $ExpectedShellWrites = if (Test-Path $PwshMsiPath) { 2 } else { 0 }
    }

    It 'exists as a selected OpenSSH service module' {
        (Test-Path -LiteralPath $ModulePath) | Should Be $true
    }

    Context 'when the module exists' {
        It 'installs the Windows OpenSSH capabilities' {
            $ModuleText = Get-Content -LiteralPath $ModulePath -Raw

            $ModuleText | Should Match ([regex]::Escape('OpenSSH.Client~~~~0.0.1.0'))
            $ModuleText | Should Match ([regex]::Escape('OpenSSH.Server~~~~0.0.1.0'))
            $ModuleText | Should Match 'Get-WindowsCapability'
            $ModuleText | Should Match 'Add-WindowsCapability'
            $ModuleText | Should Match '(?s)if\s*\(\$capability\.State\s+-eq\s+''Installed''\)\s*\{.*?continue\s*\}.*?Add-WindowsCapability'
        }

        It 'looks for the OpenSSH binaries before paying for a DISM query' {
            $ModuleText = Get-Content -LiteralPath $ModulePath -Raw

            # Get-WindowsCapability -Online measured 2.4s for the pair on every run. The
            # binaries are what the capability puts on disk, so their presence answers the
            # same question for 62ms -- with DISM still there for when one is missing.
            $ModuleText | Should Match ([regex]::Escape("System32\OpenSSH"))
            $testPathAt   = $ModuleText.IndexOf('if (Test-Path (Join-Path $opensshBin $ssh.Exe))')
            $capabilityAt = $ModuleText.IndexOf('$capability = Get-WindowsCapability')
            ($testPathAt -ge 0 -and $capabilityAt -gt $testPathAt) | Should Be $true
        }

        It 'enables the SSH server and disables the key agent only when drifted' {
            $ModuleText = Get-Content -LiteralPath $ModulePath -Raw

            $ModuleText | Should Match '\$sshd\s*=\s*Get-Service\s+-Name\s+sshd'
            $ModuleText | Should Match '\$sshd\.StartType\s+-ne\s+''Automatic'''
            $ModuleText | Should Match 'Set-Service\s+-Name\s+sshd\s+-StartupType\s+Automatic'
            $ModuleText | Should Match 'Start-Service\s+-Name\s+sshd'
            $ModuleText | Should Match '\$sshAgent\s*=\s*Get-Service\s+-Name\s+ssh-agent'
            $ModuleText | Should Match '\$sshAgent\.StartType\s+-ne\s+''Disabled'''
            $ModuleText | Should Match 'Set-Service\s+-Name\s+ssh-agent\s+-StartupType\s+Disabled'
            $ModuleText | Should Match 'Stop-Service\s+-Name\s+ssh-agent'
            $ModuleText | Should Match 'Write-Skip\s+''service:\s+sshd'
            $ModuleText | Should Match 'Write-Skip\s+''service:\s+ssh-agent'
        }

        It 'allows inbound TCP 22 and skips an already matching rule' {
            $ModuleText = Get-Content -LiteralPath $ModulePath -Raw

            $ModuleText | Should Match ([regex]::Escape('OpenSSH-Server-In-TCP'))
            $ModuleText | Should Match 'New-NetFirewallRule'
            $ModuleText | Should Match 'Set-NetFirewallRule'
            $ModuleText | Should Match 'Set-NetFirewallPortFilter'
            $ModuleText | Should Match '(?s)if\s*\(-not\s+\$firewallRule\)\s*\{\s*New-NetFirewallRule.*?-Enabled\s+True\s+-Direction\s+Inbound\s+-Protocol\s+TCP\s+-Action\s+Allow\s+-LocalPort\s+22\s*\|\s*Out-Null'
            $ModuleText | Should Match '\$firewallMatches'
            $ModuleText | Should Match 'Write-Skip\s+''firewall:\s+inbound\s+TCP\s+22'
            $ModuleText | Should Not Match 'sshd_config'
        }

        It 'points the ssh DefaultShell at the MSI build of PowerShell 7, guarded by its presence' {
            $ModuleText = Get-Content -LiteralPath $ModulePath -Raw

            $ModuleText | Should Match ([regex]::Escape('HKLM:\SOFTWARE\OpenSSH'))
            $ModuleText | Should Match ([regex]::Escape("Join-Path `$env:ProgramFiles 'PowerShell\7\pwsh.exe'"))
            $ModuleText | Should Match 'if\s*\(Test-Path\s+\$pwshExe\)'
            $ModuleText | Should Match 'DefaultShellCommandOption'
            # sshd passes the option as one argv entry, so anything with a space in it breaks
            # every non-interactive ssh call, scp and sftp included.
            $ModuleText | Should Match '\$wantedCommandOption\s*=\s*''-c'''
            $ModuleText | Should Match 'Write-Skip\s+"ssh\s+DefaultShell'
            # A packaged pwsh cannot be launched by sshd, so the WindowsApps alias must never
            # be what DefaultShell points at.
            $ModuleText | Should Not Match 'WindowsApps'
        }
    }

    Context 'when applying existing OpenSSH state' {
        BeforeEach {
            Mock Get-WindowsCapability { [pscustomobject]@{ State = 'Installed' } }
            Mock Add-WindowsCapability { }
            Mock Set-Service { }
            Mock Start-Service { }
            Mock Stop-Service { }
            Mock New-NetFirewallRule { }
            Mock Set-NetFirewallRule { }
            Mock Set-NetFirewallPortFilter { }
            Mock Write-OK { }
            Mock Write-Skip { }
            Mock Write-Info { }
            Mock Write-Warn { }
            # Never let the suite touch HKLM for real.
            Mock Set-ItemProperty { }
            Mock New-Item { }
        }

        It 'skips correct service and firewall state without mutation' {
            Mock Get-Service {
                if ($Name -eq 'sshd') {
                    [pscustomobject]@{ StartType = 'Automatic'; Status = 'Running' }
                } else {
                    [pscustomobject]@{ StartType = 'Disabled'; Status = 'Stopped' }
                }
            }
            Mock Get-NetFirewallRule {
                [pscustomobject]@{ Enabled = 'True'; Direction = 'Inbound'; Action = 'Allow' }
            }
            Mock Get-NetFirewallPortFilter {
                [pscustomobject]@{ Protocol = 'TCP'; LocalPort = '22' }
            }
            Mock Get-ItemProperty {
                [pscustomobject]@{
                    DefaultShell              = $PwshMsiPath
                    DefaultShellCommandOption = '-c'
                }
            }

            $module = & $ModulePath
            & $module.Apply @{}

            Assert-MockCalled -CommandName Set-Service -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-Service -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Stop-Service -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Set-NetFirewallRule -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Set-NetFirewallPortFilter -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Set-ItemProperty -Times 0 -Exactly -Scope It
        }

        It 'repairs drifted service and firewall state' {
            Mock Get-Service {
                if ($Name -eq 'sshd') {
                    [pscustomobject]@{ StartType = 'Manual'; Status = 'Stopped' }
                } else {
                    [pscustomobject]@{ StartType = 'Automatic'; Status = 'Running' }
                }
            }
            Mock Get-NetFirewallRule {
                [pscustomobject]@{ Enabled = 'False'; Direction = 'Inbound'; Action = 'Allow' }
            }
            Mock Get-NetFirewallPortFilter {
                [pscustomobject]@{ Protocol = 'TCP'; LocalPort = '2222' }
            }
            Mock Get-ItemProperty {
                [pscustomobject]@{ DefaultShell = 'C:\Windows\System32\cmd.exe' }
            }

            $module = & $ModulePath
            & $module.Apply @{}

            Assert-MockCalled -CommandName Set-Service -Times 2 -Exactly -Scope It
            Assert-MockCalled -CommandName Start-Service -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Stop-Service -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Set-NetFirewallRule -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Set-NetFirewallPortFilter -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Set-ItemProperty -Times $ExpectedShellWrites -Exactly -Scope It
        }
    }
}
