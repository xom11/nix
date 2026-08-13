@{
    Description = 'PowerShell modules (Terminal-Icons, PSReadLine, PSFzf, posh-git)'
    Apply = {
        param($Ctx)

        # Every entry is imported by the pwsh profile: Terminal-Icons and PSFzf in its
        # deferred block, posh-git from ps1.d/completions.ps1, PSReadLine in-box and
        # configured for MenuComplete. ZLocation was here and was not imported by
        # anything -- the profile jumps directories with zoxide.
        $Modules = @('Terminal-Icons', 'PSReadLine', 'PSFzf', 'posh-git')

        # AllUsers so pwsh 7 sees them: CurrentUser from PS 5.1 only populates
        # ~\Documents\WindowsPowerShell\Modules, which pwsh 7 does not include.
        $sharedPath = 'C:\Program Files\WindowsPowerShell\Modules'
        $missing = @()
        foreach ($m in $Modules) {
            $have = Get-Module -ListAvailable -Name $m |
                    Where-Object { $_.ModuleBase -like "$sharedPath*" } |
                    Select-Object -First 1
            if ($have) { Write-Skip "psmodule:$m" } else { $missing += $m }
        }
        if (-not $missing) { return }

        # Only past the early exit: Get-PackageProvider and Get-PSRepository measured
        # ~3s together, paid on every run of a converged machine to prepare an install
        # that never happened. The lookup above costs 13-42ms each.
        if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
            Write-Info 'Install-PackageProvider NuGet'
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
        }
        $repo = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
        if ($repo -and $repo.InstallationPolicy -ne 'Trusted') {
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }

        foreach ($m in $missing) {
            Write-Info "Install-Module $m -Scope AllUsers"
            Install-Module -Name $m -Scope AllUsers -Force -AllowClobber -SkipPublisherCheck
        }
    }
}
