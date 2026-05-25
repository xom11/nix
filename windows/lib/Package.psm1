function Update-Path {
    # Refresh PATH from registry (Machine + User) so tools just installed are visible.
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')
}

function Test-IsAdmin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Invoke a command at Medium IL (non-admin) when running as admin, native otherwise.
# Used for scoop which refuses to run as administrator.
function Invoke-AsUser {
    if (Test-IsAdmin) {
        if (-not (Get-Command gsudo -ErrorAction SilentlyContinue)) {
            throw "gsudo missing - install gerardog.gsudo via winget first"
        }
        & gsudo --integrity Medium @args
    } else {
        & $args[0] @($args | Select-Object -Skip 1)
    }
}

function Install-Scoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) { return $true }

    if (Test-IsAdmin) {
        if (-not (Get-Command gsudo -ErrorAction SilentlyContinue)) {
            Write-Fail "scoop bootstrap requires gsudo (install gerardog.gsudo via winget first)"
            return $false
        }
        Write-Info "bootstrapping scoop via gsudo --integrity Medium"
        gsudo --integrity Medium powershell -NoProfile -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; Invoke-Expression (Invoke-RestMethod -Uri 'https://get.scoop.sh')"
    } else {
        Write-Info "bootstrapping scoop"
        Invoke-Expression (Invoke-RestMethod -Uri 'https://get.scoop.sh')
    }

    Update-Path
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Fail "scoop bootstrap finished but scoop not in PATH"
        return $false
    }

    # Tell scoop to use system 7-Zip (avoids ARM64 7zip pre_install bug in main bucket)
    if (Get-Command 7z -ErrorAction SilentlyContinue) {
        Write-Info "scoop config 7zipextract_use_external true"
        Invoke-AsUser scoop config 7zipextract_use_external $true | Out-Null
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

    # Add buckets
    if ($Buckets) {
        $current = @(Invoke-AsUser scoop bucket list 2>$null | ForEach-Object { $_.Name })
        foreach ($b in $Buckets) {
            if ($current -notcontains $b) {
                Write-Info "scoop bucket add $b"
                Invoke-AsUser scoop bucket add $b
            }
        }
    }

    $installed = @(Invoke-AsUser scoop list 6>$null | ForEach-Object { $_.Name } | Where-Object { $_ })
    foreach ($pkg in $Packages) {
        if ($installed -contains $pkg) {
            Write-Skip "scoop:$pkg"
        } else {
            Write-Info "scoop install $pkg"
            Invoke-AsUser scoop install $pkg
        }
    }
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

    # Use AllUsers scope so pwsh 7 sees the modules too. CurrentUser scope from
    # Windows PowerShell 5.1 only populates ~\Documents\WindowsPowerShell\Modules
    # which pwsh 7 does NOT include in $PSModulePath by default.
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

Export-ModuleMember -Function Update-Path, Test-IsAdmin, Invoke-AsUser, Install-Scoop, Install-ScoopPackages, Install-WingetPackages, Install-NpmPackages, Install-PSModules
