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

function Get-ScoopNativeArchitecture {
    # The architecture scoop should be installing for, named the way its manifests name it.
    #
    # PROCESSOR_ARCHITECTURE describes the *calling process*, not the machine: an x64
    # PowerShell running emulated on an ARM64 laptop answers AMD64. Believing it is how a14
    # ended up with its whole toolchain built for the wrong CPU -- neovim alone paid an extra
    # ~410ms of Prism translation on every launch, and nothing anywhere said why.
    # PROCESSOR_ARCHITEW6432 exists only while emulated, and carries the real machine.
    [CmdletBinding()]
    param(
        [string]$ProcessArch = $env:PROCESSOR_ARCHITECTURE,
        [string]$NativeArch  = $env:PROCESSOR_ARCHITEW6432
    )

    $arch = if ($NativeArch) { $NativeArch } else { $ProcessArch }
    switch ($arch) {
        'ARM64' { 'arm64' }
        'AMD64' { '64bit' }
        'IA64'  { '64bit' }
        'x86'   { '32bit' }
        default { '64bit' }
    }
}

function Test-ScoopArchDrift {
    # Is this already-installed app built for the wrong architecture, and can that be fixed?
    #
    # Deliberately says no unless it is sure. Kept free of any filesystem or scoop call so the
    # decision can be tested against fabricated inputs.
    [CmdletBinding()]
    param(
        [string]$NativeArch,
        [string]$InstalledArch,
        [string[]]$ManifestArchs
    )

    if (-not $NativeArch)               { return $false }
    # An app installed by an older scoop has no install.json. "Unknown" must not read as
    # "wrong", or every apply would uninstall and refetch it.
    if (-not $InstalledArch)            { return $false }
    if ($InstalledArch -eq $NativeArch) { return $false }
    if (-not $ManifestArchs)            { return $false }

    # Only worth a download when the manifest actually ships a build for this machine. age,
    # shfmt and stylua are x64-only; reinstalling them changes nothing and risks the gap
    # described in Install-ScoopPackages for no gain at all.
    return ([bool]($ManifestArchs -contains $NativeArch))
}

function Get-ScoopAppRoot {
    param([Parameter(Mandatory)][string]$App)
    $root = if ($env:SCOOP) { $env:SCOOP } else { Join-Path $env:USERPROFILE 'scoop' }
    Join-Path (Join-Path $root 'apps') $App
}

function Test-ScoopAppPresent {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$App)
    Test-Path (Join-Path (Get-ScoopAppRoot $App) 'current')
}

function Get-ScoopInstalledArchitecture {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$App)

    $file = Join-Path (Get-ScoopAppRoot $App) 'current\install.json'
    if (-not (Test-Path $file)) { return '' }
    try { return [string](Get-Content $file -Raw | ConvertFrom-Json).architecture } catch { return '' }
}

function Get-ScoopManifestArchitectures {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$App)

    $file = Join-Path (Get-ScoopAppRoot $App) 'current\manifest.json'
    if (-not (Test-Path $file)) { return ,@() }
    try {
        $manifest = Get-Content $file -Raw | ConvertFrom-Json
        if ($manifest.architecture) { return ,@($manifest.architecture.PSObject.Properties.Name) }
    } catch { }
    return ,@()
}

function Get-ScoopAppProcess {
    # Names of the app's own executables that are running right now. scoop refuses to
    # uninstall over a live process, and a half-finished swap is the worst outcome here.
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$App)

    $current = Join-Path (Get-ScoopAppRoot $App) 'current'
    if (-not (Test-Path $current)) { return ,@() }

    $names = Get-ChildItem $current -Recurse -File -Filter *.exe -ErrorAction SilentlyContinue |
             Select-Object -ExpandProperty BaseName -Unique
    $live = foreach ($n in $names) {
        if (Get-Process -Name $n -ErrorAction SilentlyContinue) { $n }
    }
    return ,@($live)
}

function Set-ScoopArchitectureDefault {
    # Without this, a fresh install on an ARM64 machine silently takes the 64bit branch of
    # every manifest -- scoop's default_architecture is '64bit' until told otherwise.
    $native  = Get-ScoopNativeArchitecture
    $current = (scoop config default_architecture 2>$null | Out-String).Trim()
    if ($current -eq $native) { return }

    Write-Info "scoop config default_architecture $native"
    scoop config default_architecture $native | Out-Null
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
        [string[]]$Buckets,

        # Apps that keep whatever architecture they are already on. Every entry leaves an
        # emulated binary on an ARM64 machine, so each one needs a reason at the call site.
        [string[]]$KeepArchitecture
    )

    if (-not (Install-Scoop)) { return }

    Set-ScoopArchitectureDefault
    $native = Get-ScoopNativeArchitecture

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

        # -KeepArchitecture takes two forms, same 'name=value' convention the bucket list
        # above uses:
        #
        #   'kanata'         leave whatever is installed alone, whatever it is
        #   'opencode=64bit' this app only works on that architecture -- install it that way
        #                    on a fresh machine, and correct it if it is on another
        #
        # The second form exists because the bare form only ever ran for apps that were
        # ALREADY installed. A fresh arm64 machine fell through to the plain install below,
        # got the native build, and was then pinned to it forever -- so the pin read as
        # protection while guaranteeing the broken architecture. Nothing reported that,
        # because from the sweep's point of view everything went fine.
        $pinArch = $null
        $pinned  = $false
        foreach ($k in $KeepArchitecture) {
            $kp = $k -split '=', 2
            if ($kp[0] -eq $name) {
                $pinned = $true
                if ($kp.Count -eq 2) { $pinArch = $kp[1] }
                break
            }
        }

        if ($installed -notcontains $name) {
            if ($pinArch) {
                Write-Info "scoop install $pkg (architecture forced to $pinArch)"
                scoop install $pkg --arch $pinArch
            } else {
                Write-Info "scoop install $pkg"
                scoop install $pkg
            }
            continue
        }

        if ($pinned -and -not $pinArch) {
            Write-Skip "scoop:$pkg (architecture pinned)"
            continue
        }

        # Presence used to be the whole test, which meant setting default_architecture could
        # only ever help a machine nobody had installed on yet -- a14 sat on 17 emulated
        # packages that no number of applies would have corrected.
        $installedArch = Get-ScoopInstalledArchitecture -App $name
        if ($pinArch) {
            # A forced architecture answers the question outright: the manifest-aware drift
            # test would refuse the swap here, because it is deliberately going *against*
            # what this machine natively wants.
            $want  = $pinArch
            $drift = [bool]($installedArch -and $installedArch -ne $pinArch)
        } else {
            $want  = $native
            $drift = Test-ScoopArchDrift -NativeArch $native -InstalledArch $installedArch `
                                         -ManifestArchs (Get-ScoopManifestArchitectures -App $name)
        }
        if (-not $drift) {
            Write-Skip "scoop:$pkg"
            continue
        }

        # scoop cannot change an installed app's architecture in place, so this is an
        # uninstall followed by an install, and the gap between them is the dangerous part.
        # Reinstalling rustup on a14 uninstalled it and then failed every retry: the
        # post_install rustup-init.exe from the previous attempt was still resident and held
        # a lock on the exact file the new install had to write. The machine was left with no
        # rustup and nothing on screen explaining it. So: never start over a live process,
        # and always check the app came back.
        $running = @(Get-ScoopAppProcess -App $name)
        if ($running.Count) {
            Write-Warn "scoop:$pkg is $installedArch, wanted $native -- left alone, still running ($($running -join ', '))"
            continue
        }

        Write-Info "scoop reinstall $pkg ($installedArch -> $want)"
        scoop uninstall $name
        if ($pinArch) { scoop install $pkg --arch $pinArch } else { scoop install $pkg }
        if (Test-ScoopAppPresent -App $name) {
            Write-OK "scoop:$pkg now $(Get-ScoopInstalledArchitecture -App $name)"
        } else {
            Write-Fail "scoop:$pkg was uninstalled and did not come back -- install it by hand before relying on it"
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

Export-ModuleMember -Function Update-Path, Test-IsAdmin, Install-Scoop, Install-ScoopPackages, Get-ScoopNativeArchitecture, Test-ScoopArchDrift, Test-ScoopAppPresent, Get-ScoopInstalledArchitecture, Get-ScoopManifestArchitectures, Get-ScoopAppProcess, Set-ScoopArchitectureDefault, Test-WingetPackageInstalled, ConvertFrom-WingetList, Get-WingetInstalledIds, Install-WingetPackages, Install-NpmPackages, Install-PSModules
