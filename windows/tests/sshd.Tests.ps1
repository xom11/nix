Describe 'windows services.sshd module' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ModulePath = Join-Path $RepoRoot 'windows\modules\services\sshd\module.ps1'
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

        It 'enables the SSH server and disables the key agent' {
            $ModuleText = Get-Content -LiteralPath $ModulePath -Raw

            $ModuleText | Should Match 'Set-Service\s+-Name\s+sshd\s+-StartupType\s+Automatic'
            $ModuleText | Should Match 'Start-Service\s+-Name\s+sshd'
            $ModuleText | Should Match '(?s)if\s*\(\(Get-Service\s+-Name\s+sshd\)\.Status\s+-ne\s+''Running''\)\s*\{\s*Start-Service\s+-Name\s+sshd\s*\}'
            $ModuleText | Should Match 'Set-Service\s+-Name\s+ssh-agent\s+-StartupType\s+Disabled'
            $ModuleText | Should Match 'Stop-Service\s+-Name\s+ssh-agent'
            $ModuleText | Should Match '(?s)if\s*\(\(Get-Service\s+-Name\s+ssh-agent\)\.Status\s+-ne\s+''Stopped''\)\s*\{\s*Stop-Service\s+-Name\s+ssh-agent(?:\s+-Force)?\s*\}'
        }

        It 'allows inbound TCP 22 without managing sshd_config' {
            $ModuleText = Get-Content -LiteralPath $ModulePath -Raw

            $ModuleText | Should Match ([regex]::Escape('OpenSSH-Server-In-TCP'))
            $ModuleText | Should Match 'New-NetFirewallRule'
            $ModuleText | Should Match 'Set-NetFirewallRule'
            $ModuleText | Should Match 'Set-NetFirewallPortFilter'
            $ModuleText | Should Match '(?s)if\s*\(-not\s+\$firewallRule\)\s*\{\s*New-NetFirewallRule.*?-Enabled\s+True\s+-Direction\s+Inbound\s+-Protocol\s+TCP\s+-Action\s+Allow\s+-LocalPort\s+22\s*\|\s*Out-Null\s*\}'
            $ModuleText | Should Match '(?s)else\s*\{\s*Set-NetFirewallRule\s+-Name\s+\$firewallRuleName\s+-Enabled\s+True\s+-Direction\s+Inbound\s+-Action\s+Allow\s+\$firewallRule\s*\|\s*Get-NetFirewallPortFilter\s*\|\s*Set-NetFirewallPortFilter\s+-Protocol\s+TCP\s+-LocalPort\s+22\s*\}'
            $ModuleText | Should Not Match 'sshd_config'
        }
    }
}
