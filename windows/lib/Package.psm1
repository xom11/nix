# What outlived the move to dotpkg (2026-08-12): the winget and scoop install
# paths -- 13 functions, ~300 lines -- are `dotpkg apply` now.
#
# One capability went with them rather than being kept: Test-ScoopArchDrift and
# Set-ScoopArchitectureDefault used to FIX an architecture mismatch, which is how
# a14 shed 17 emulated packages on 2026-08-03. dotpkg only reports drift (item 8
# in its OPEN-ITEMS.md).

function Update-Path {
    # Refresh PATH from registry (Machine + User) so tools just installed are visible.
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')
}

function Get-NativeArchitecture {
    # The architecture of the MACHINE, in Windows' own vocabulary (ARM64 / AMD64 / x86).
    #
    # PROCESSOR_ARCHITECTURE describes the *calling process*, not the machine: an x64
    # PowerShell running emulated on an ARM64 laptop answers AMD64. Believing it is how a14
    # ended up with its whole toolchain built for the wrong CPU -- neovim alone paid an extra
    # ~410ms of Prism translation on every launch, and nothing anywhere said why.
    # PROCESSOR_ARCHITEW6432 exists only while emulated, and carries the real machine.
    #
    # Every module that has to pick a build calls this and then maps the answer into whatever
    # vocabulary its own source uses -- scoop says 'arm64/64bit/32bit' (below), the PowerShell
    # release assets say 'arm64/x64/x86'. Three translations are fine; three readings of the
    # environment were not, because only one of them got the emulation case right.
    [CmdletBinding()]
    param(
        [string]$ProcessArch = $env:PROCESSOR_ARCHITECTURE,
        [string]$NativeArch  = $env:PROCESSOR_ARCHITEW6432
    )

    if ($NativeArch) { return $NativeArch }
    return $ProcessArch
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

function Install-NpmPackages {
    [CmdletBinding()]
    param([string[]]$Packages)

    # Nothing to do, and `npm ls -g` is not free: measured on a14 at 2077-2332 ms warm across
    # three consecutive runs (much worse cold). The caller's list has been empty for a while,
    # so that was two seconds of every apply spent listing packages in order to compare them
    # against nothing.
    if (-not $Packages) { return }

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

Export-ModuleMember -Function Update-Path, Install-Scoop, Get-NativeArchitecture, Install-NpmPackages, Install-PSModules
