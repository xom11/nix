function Update-Path {
    # Refresh PATH from registry (Machine + User) so tools just installed are visible.
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')
}

function Test-IsAdmin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-WingetPackageInstalled {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Id)

    # The exact, always-correct answer, and the fallback whenever the bulk table below cannot
    # confirm an id. It costs a full winget startup (~0.9s measured), which is why it is no
    # longer the first thing tried for every package.
    $output = winget list --id $Id --exact --disable-interactivity --accept-source-agreements 2>$null | Out-String
    return ($LASTEXITCODE -eq 0) -and ($output -notmatch 'No installed package found')
}

function ConvertFrom-WingetList {
    # Read the Id column out of a `winget list` table by header position.
    #
    # An earlier version substring-matched the whole dump and got burned twice: winget truncates
    # a long id to the console width ('Microsoft.Win…' over SSH), and a substring cannot tell
    # 'Microsoft.PowerShell' from 'Microsoft.PowerShell.Preview'. Both are handled here rather
    # than avoided -- ids are cut out of their column and compared whole, and any cell that
    # cannot be read with confidence is left OUT of the set. Being absent from the set only
    # sends the caller to the exact per-package query; it never reads as "not installed".
    #
    # Kept free of any winget call so it can be tested against fabricated tables.
    [CmdletBinding()]
    param([string[]]$Lines)

    $ids = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    if (-not $Lines) { return ,$ids }

    $headerIndex = -1
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '^Name\s+Id\s+Version') { $headerIndex = $i; break }
    }
    # No header (a localised Windows, an error dump, an empty result): hand back nothing and
    # let every id fall through to the exact query.
    if ($headerIndex -lt 0 -or ($headerIndex + 1) -ge $Lines.Count) { return ,$ids }

    $header  = $Lines[$headerIndex]
    $idStart = $header.IndexOf('Id')
    $idEnd   = $header.IndexOf('Version')
    if ($idStart -lt 0 -or $idEnd -le $idStart) { return ,$ids }

    foreach ($line in $Lines[($headerIndex + 1)..($Lines.Count - 1)]) {
        if ($null -eq $line -or $line.Length -le $idStart) { continue }
        if ($line -match '^\s*-+\s*$') { continue }

        $width = [Math]::Min($idEnd - $idStart, $line.Length - $idStart)
        $id = $line.Substring($idStart, $width).Trim()
        if (-not $id) { continue }

        # An id never contains whitespace, so whitespace here means the columns have drifted
        # and this row cannot be trusted. U+2026 is winget's own truncation marker.
        if ($id -match '\s' -or $id.Contains([char]0x2026)) { continue }
        [void]$ids.Add($id)
    }

    return ,$ids
}

function Get-WingetInstalledIds {
    $lines = @(winget list --disable-interactivity --accept-source-agreements 2>$null)
    return ,(ConvertFrom-WingetList -Lines $lines)
}

function Install-WingetPackages {
    [CmdletBinding()]
    param([string[]]$Packages)

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Warn "winget not available - skipping"
        return
    }

    # One bulk table up front (~1.5s) answers for nearly every package. Asking winget per
    # package instead cost ~0.9s each -- 14.5s of a 28s run, all of it to confirm that nothing
    # had changed.
    $installedIds = Get-WingetInstalledIds

    foreach ($id in $Packages) {
        $present = $installedIds.Contains($id)
        if (-not $present) {
            # Store apps list under a different id than the one they install by, so a miss here
            # is not proof of absence -- pay for the exact query before deciding to install.
            $present = Test-WingetPackageInstalled -Id $id
        }

        if ($present) {
            Write-Skip "winget:$id"
        } else {
            Write-Info "winget install $id"
            winget install --id $id --exact --silent --disable-interactivity `
                --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -ne 0) {
                Write-Warn "winget install $id exited with $LASTEXITCODE"
            }
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

    # Use AllUsers scope so pwsh 7 sees the modules (CurrentUser from PS 5.1 only populates
    # ~\Documents\WindowsPowerShell\Modules, which pwsh 7 does NOT include by default).
    $sharedPath = 'C:\Program Files\WindowsPowerShell\Modules'
    $missing = @()
    foreach ($m in $Modules) {
        $existing = Get-Module -ListAvailable -Name $m |
                    Where-Object { $_.ModuleBase -like "$sharedPath*" } |
                    Select-Object -First 1
        if ($existing) {
            Write-Skip "psmodule:$m"
        } else {
            $missing += $m
        }
    }
    if (-not $missing) { return }

    # Only reached when something actually has to be installed. Get-PackageProvider and
    # Get-PSRepository between them measured ~3s, and on a converged machine they were paid
    # every run to prepare for an install that never happened. Looking the modules up first
    # costs nothing worth counting (13-42ms each).
    if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
        Write-Info "Install-PackageProvider NuGet"
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

Export-ModuleMember -Function Update-Path, Test-IsAdmin, Install-Scoop, Install-ScoopPackages, Test-WingetPackageInstalled, ConvertFrom-WingetList, Get-WingetInstalledIds, Install-WingetPackages, Install-NpmPackages, Install-PSModules
