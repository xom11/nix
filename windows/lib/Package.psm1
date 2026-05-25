function Update-Path {
    # Refresh PATH from registry (Machine + User) so tools just installed are visible.
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')
}

function Install-WingetPackages {
    [CmdletBinding()]
    param([string[]]$Packages)

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Warn "winget not available - skipping"
        return
    }

    $installedRaw = winget list --accept-source-agreements --disable-interactivity 2>$null
    foreach ($id in $Packages) {
        if ($installedRaw -match [regex]::Escape($id)) {
            Write-Skip "winget:$id"
        } else {
            Write-Info "winget install $id"
            winget install --id $id --exact --silent --disable-interactivity `
                --accept-package-agreements --accept-source-agreements
        }
    }
}

function Install-NpmPackages {
    [CmdletBinding()]
    param([string[]]$Packages)

    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Warn "npm not installed - skipping (install Node.js via winget first)"
        return
    }
    $installed = @(npm ls -g --depth=0 --parseable 2>$null)
    foreach ($pkg in $Packages) {
        if ($installed -match [regex]::Escape($pkg)) {
            Write-Skip "npm:$pkg"
        } else {
            Write-Info "npm i -g $pkg"
            npm install -g $pkg
        }
    }
}

function Install-PSModules {
    [CmdletBinding()]
    param([string[]]$Modules)

    if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
        Write-Info "Install-PackageProvider NuGet"
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
    }
    $repo = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
    if ($repo -and $repo.InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }

    foreach ($m in $Modules) {
        if (Get-Module -ListAvailable -Name $m) {
            Write-Skip "psmodule:$m"
        } else {
            Write-Info "Install-Module $m"
            Install-Module -Name $m -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck
        }
    }
}

Export-ModuleMember -Function Update-Path, Install-WingetPackages, Install-NpmPackages, Install-PSModules
