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

        $sshd = Get-Service -Name sshd
        $sshdChanged = $false
        if ($sshd.StartType -ne 'Automatic') {
            Set-Service -Name sshd -StartupType Automatic
            $sshdChanged = $true
        }
        if ($sshd.Status -ne 'Running') {
            Start-Service -Name sshd
            $sshdChanged = $true
        }
        if ($sshdChanged) {
            Write-OK 'service: sshd (Automatic, Running)'
        } else {
            Write-Skip 'service: sshd (Automatic, Running)'
        }

        $firewallRuleName = 'OpenSSH-Server-In-TCP'
        $firewallRule = Get-NetFirewallRule -Name $firewallRuleName -ErrorAction SilentlyContinue
        if (-not $firewallRule) {
            New-NetFirewallRule -Name $firewallRuleName -DisplayName 'OpenSSH Server (sshd)' `
                -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
            Write-OK 'firewall: inbound TCP 22 (OpenSSH-Server-In-TCP)'
        } else {
            $portFilter = $firewallRule | Get-NetFirewallPortFilter
            $firewallMatches = "$($firewallRule.Enabled)" -eq 'True' -and
                "$($firewallRule.Direction)" -eq 'Inbound' -and
                "$($firewallRule.Action)" -eq 'Allow' -and
                "$($portFilter.Protocol)" -eq 'TCP' -and
                "$($portFilter.LocalPort)" -eq '22'
            if ($firewallMatches) {
                Write-Skip 'firewall: inbound TCP 22 (OpenSSH-Server-In-TCP)'
            } else {
                Set-NetFirewallRule -Name $firewallRuleName -Enabled True -Direction Inbound -Action Allow
                $portFilter | Set-NetFirewallPortFilter -Protocol TCP -LocalPort 22
                Write-OK 'firewall: inbound TCP 22 (OpenSSH-Server-In-TCP)'
            }
        }

        # Without DefaultShell, sshd hands the session to cmd.exe, which lands the user in
        # Windows PowerShell 5.1 -- a shell with no profile here, since the repo only links one
        # into Documents\PowerShell (pwsh 7). Point it at the MSI build under Program Files:
        # the MSIX/Store build of PowerShell 7 cannot be launched from an sshd logon session at
        # all (it fails with "Access is denied"), so an installed-but-packaged pwsh is not
        # usable here. Skip quietly if the MSI build is absent rather than break SSH.
        $pwshExe = Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'
        if (Test-Path $pwshExe) {
            $sshRegPath = 'HKLM:\SOFTWARE\OpenSSH'
            # -NoProfile applies only to `ssh <host> <command>`; an interactive `ssh <host>`
            # still loads the profile. Non-interactive calls skip the ~2s profile cost.
            $wantedCommandOption = '-NoProfile -Command'

            if (-not (Test-Path $sshRegPath)) {
                New-Item -Path $sshRegPath -Force | Out-Null
            }
            $sshReg = Get-ItemProperty -Path $sshRegPath -ErrorAction SilentlyContinue
            if ($sshReg.DefaultShell -eq $pwshExe -and $sshReg.DefaultShellCommandOption -eq $wantedCommandOption) {
                Write-Skip "ssh DefaultShell: pwsh 7"
            } else {
                Set-ItemProperty -Path $sshRegPath -Name DefaultShell -Value $pwshExe -Type String
                Set-ItemProperty -Path $sshRegPath -Name DefaultShellCommandOption -Value $wantedCommandOption -Type String
                Write-OK "ssh DefaultShell: $pwshExe"
            }
        } else {
            Write-Warn "PowerShell 7 (MSI) missing at $pwshExe - leaving ssh on the cmd.exe default"
        }

        $sshAgent = Get-Service -Name ssh-agent
        $sshAgentChanged = $false
        if ($sshAgent.StartType -ne 'Disabled') {
            Set-Service -Name ssh-agent -StartupType Disabled
            $sshAgentChanged = $true
        }
        if ($sshAgent.Status -ne 'Stopped') {
            Stop-Service -Name ssh-agent -Force
            $sshAgentChanged = $true
        }
        if ($sshAgentChanged) {
            Write-OK 'service: ssh-agent (Disabled, Stopped)'
        } else {
            Write-Skip 'service: ssh-agent (Disabled, Stopped)'
        }
    }
}
