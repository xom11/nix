function Update-Path {
    # Refresh PATH from registry (Machine + User) so tools just installed are visible.
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')
}

function Test-IsAdmin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
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

function Install-Scoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) { return $true }

    Write-Info "bootstrapping scoop"
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-Expression (Invoke-RestMethod -Uri 'https://get.scoop.sh')
    } catch {
        Write-Fail "scoop bootstrap: $_"
        return $false
    }

    Update-Path
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Fail "scoop bootstrap finished but scoop not in PATH"
        return $false
    }
    return $true
}

function Install-ScoopPackages {
    [CmdletBinding()]
    param(
        [string[]]$Packages,
        [string[]]$Buckets
    )

    if (-not (Install-Scoop)) { return }

    if ($Buckets) {
        $current = @(scoop bucket list 2>$null | ForEach-Object { $_.Name })
        foreach ($b in $Buckets) {
            # 'name=url' for custom buckets, 'name' for known buckets
            $parts = $b -split '=', 2
            $name = $parts[0]
            $url  = if ($parts.Count -eq 2) { $parts[1] } else { $null }
            if ($current -notcontains $name) {
                if ($url) {
                    Write-Info "scoop bucket add $name $url"
                    scoop bucket add $name $url
                } else {
                    Write-Info "scoop bucket add $name"
                    scoop bucket add $name
                }
            }
        }
    }

    $installed = @(scoop list 6>$null | ForEach-Object { $_.Name } | Where-Object { $_ })
    foreach ($pkg in $Packages) {
        # Strip 'bucket/' prefix when checking installed (scoop list shows bare names)
        $name = ($pkg -split '/', 2)[-1]
        if ($installed -contains $name) {
            Write-Skip "scoop:$pkg"
        } else {
            Write-Info "scoop install $pkg"
            scoop install $pkg
        }
    }
}

function Install-NpmPackages {
    [CmdletBinding()]
    param([string[]]$Packages)

    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Warn "npm not installed - skipping (install nodejs via scoop first)"
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

    # Use AllUsers scope so pwsh 7 sees the modules (CurrentUser from PS 5.1 only populates
    # ~\Documents\WindowsPowerShell\Modules, which pwsh 7 does NOT include by default).
    $sharedPath = 'C:\Program Files\WindowsPowerShell\Modules'
    foreach ($m in $Modules) {
        $existing = Get-Module -ListAvailable -Name $m |
                    Where-Object { $_.ModuleBase -like "$sharedPath*" } |
                    Select-Object -First 1
        if ($existing) {
            Write-Skip "psmodule:$m"
        } else {
            Write-Info "Install-Module $m -Scope AllUsers"
            Install-Module -Name $m -Scope AllUsers -Force -AllowClobber -SkipPublisherCheck
        }
    }
}

Export-ModuleMember -Function Update-Path, Test-IsAdmin, Install-Scoop, Install-ScoopPackages, Install-WingetPackages, Install-NpmPackages, Install-PSModules
