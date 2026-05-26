@{
    Description = 'OpenSSH: built-in client/server, sshd service, and inbound firewall'
    Apply = {
        param($Ctx)

        foreach ($capabilityName in @(
            'OpenSSH.Client~~~~0.0.1.0'
            'OpenSSH.Server~~~~0.0.1.0'
        )) {
            $capability = Get-WindowsCapability -Online -Name $capabilityName
            if ($capability.State -eq 'Installed') {
                Write-Skip "capability: $capabilityName"
                continue
            }

            Write-Info "install capability: $capabilityName"
            Add-WindowsCapability -Online -Name $capabilityName | Out-Null
            Write-OK "capability: $capabilityName"
        }

        Set-Service -Name sshd -StartupType Automatic
        if ((Get-Service -Name sshd).Status -ne 'Running') {
            Start-Service -Name sshd
        }
        Write-OK 'service: sshd (Automatic, Running)'

        $firewallRuleName = 'OpenSSH-Server-In-TCP'
        $firewallRule = Get-NetFirewallRule -Name $firewallRuleName -ErrorAction SilentlyContinue
        if (-not $firewallRule) {
            New-NetFirewallRule -Name $firewallRuleName -DisplayName 'OpenSSH Server (sshd)' `
                -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
        } else {
            Set-NetFirewallRule -Name $firewallRuleName -Enabled True -Direction Inbound -Action Allow
            $firewallRule | Get-NetFirewallPortFilter |
                Set-NetFirewallPortFilter -Protocol TCP -LocalPort 22
        }
        Write-OK 'firewall: inbound TCP 22 (OpenSSH-Server-In-TCP)'

        Set-Service -Name ssh-agent -StartupType Disabled
        if ((Get-Service -Name ssh-agent).Status -ne 'Stopped') {
            Stop-Service -Name ssh-agent -Force
        }
        Write-OK 'service: ssh-agent (Disabled, Stopped)'
    }
}
