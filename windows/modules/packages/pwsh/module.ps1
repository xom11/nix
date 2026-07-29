@{
    Description = 'PowerShell 7 from the MSI release (winget only ships MSIX, which sshd cannot launch)'
    Apply = {
        param($Ctx)

        # winget's Microsoft.PowerShell manifest offers a single installer type, msix, for
        # every architecture. A packaged pwsh cannot be started from an sshd logon session --
        # it fails with "Access is denied" -- so `ssh <host>` would be stuck on Windows
        # PowerShell 5.1 and services.sshd would have nothing to point DefaultShell at.
        # The MSI is published on the same GitHub release, so take it from there.

        $target = Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'

        function Get-InstalledPwshVersion {
            param([string]$Path)
            if (-not (Test-Path $Path)) { return $null }
            return [version](((Get-Item $Path).VersionInfo.ProductVersion) -replace '-.*$', '')
        }

        function Remove-PackagedPwsh {
            # Only safe once an unpackaged pwsh exists. Left in place it shadows nothing
            # useful, shows up as a second Microsoft.PowerShell row in `winget list`, and is
            # the build that cannot run over SSH in the first place. Non-fatal: Appx removal
            # wants a real user session and can legitimately fail from an SSH session.
            $appx = Get-AppxPackage -Name Microsoft.PowerShell -ErrorAction SilentlyContinue
            if (-not $appx) { return }
            try {
                $appx | Remove-AppxPackage -ErrorAction Stop
                Write-OK "removed MSIX PowerShell $($appx.Version)"
            } catch {
                Write-Warn "could not remove the MSIX PowerShell (run apply from a desktop session): $_"
            }
        }

        $installed = Get-InstalledPwshVersion -Path $target

        $arch = switch ($env:PROCESSOR_ARCHITECTURE) {
            'ARM64' { 'arm64' }
            'AMD64' { 'x64' }
            'x86'   { 'x86' }
            default { $null }
        }
        if (-not $arch) {
            Write-Warn "unsupported architecture '$env:PROCESSOR_ARCHITECTURE' - skipping pwsh"
            return
        }

        try {
            $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest' `
                -Headers @{ 'User-Agent' = 'nix-windows-apply' } -TimeoutSec 30
        } catch {
            # Offline or rate-limited: an existing install is still fine, a missing one is not.
            if ($installed) {
                Write-Skip "pwsh 7 (MSI): $installed (release check failed)"
                Remove-PackagedPwsh
            } else {
                Write-Warn "cannot reach the PowerShell release feed and pwsh is not installed: $_"
            }
            return
        }

        $version = $release.tag_name -replace '^v', ''
        $latest  = [version]($version -replace '-.*$', '')

        if ($installed -and $installed -ge $latest) {
            Write-Skip "pwsh 7 (MSI): $installed"
            Remove-PackagedPwsh
            return
        }

        $assetName = "PowerShell-$version-win-$arch.msi"
        $asset = $release.assets | Where-Object { $_.name -eq $assetName } | Select-Object -First 1
        if (-not $asset) {
            Write-Warn "no MSI named $assetName in release $($release.tag_name)"
            return
        }

        $msi = Join-Path $env:TEMP $asset.name
        Write-Info "downloading $($asset.name)"
        try {
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $msi -UseBasicParsing
        } catch {
            Write-Fail "download failed: $_"
            return
        }

        Write-Info ("{0} pwsh {1}" -f $(if ($installed) { 'upgrading to' } else { 'installing' }), $latest)
        $proc = Start-Process msiexec.exe -Wait -PassThru -ArgumentList @(
            '/package', "`"$msi`""
            '/quiet'
            '/norestart'
            'ADD_PATH=1'
            'REGISTER_MANIFEST=1'
            'ENABLE_PSREMOTING=0'
        )
        Remove-Item $msi -Force -ErrorAction SilentlyContinue

        if ($proc.ExitCode -ne 0) {
            Write-Fail "msiexec exited with $($proc.ExitCode)"
            return
        }
        if (-not (Test-Path $target)) {
            Write-Fail "msiexec reported success but $target is missing"
            return
        }

        Write-OK "pwsh 7 (MSI): $latest"
        Remove-PackagedPwsh
    }
}
