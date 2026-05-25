[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$HostName = $env:COMPUTERNAME,

    # Skip self-elevation (use when running over SSH where UAC prompt cannot show).
    # Caller must already be admin, otherwise the script errors out.
    [switch]$NoElevate
)

$ErrorActionPreference = 'Stop'

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Self-elevate upfront. Everything runs as admin; scoop is de-elevated internally via gsudo.
if (-not $IsAdmin) {
    if ($NoElevate -or $env:SSH_CLIENT -or $env:SSH_CONNECTION) {
        Write-Host "ERROR: not running as admin. Open elevated pwsh (or SSH as a local admin user)." -ForegroundColor Red
        exit 1
    }
    Start-Process powershell.exe -Verb RunAs -ArgumentList @(
        '-NoProfile'
        '-ExecutionPolicy', 'Bypass'
        '-File', "`"$PSCommandPath`""
        $HostName
    )
    exit
}

$WindowsDir = $PSScriptRoot
$RepoRoot   = Split-Path $WindowsDir -Parent

$HostFile = Join-Path $RepoRoot "hosts\$HostName\windows.ps1"
if (-not (Test-Path $HostFile)) {
    Write-Host "Host file not found: $HostFile" -ForegroundColor Red
    Write-Host "Available Windows hosts:" -ForegroundColor Yellow
    Get-ChildItem (Join-Path $RepoRoot 'hosts') -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName 'windows.ps1') } |
        ForEach-Object { Write-Host "  - $($_.Name)" }
    exit 1
}

Import-Module (Join-Path $WindowsDir 'lib\Logging.psm1') -Force
Import-Module (Join-Path $WindowsDir 'lib\Symlink.psm1') -Force
Import-Module (Join-Path $WindowsDir 'lib\Package.psm1') -Force

$Ctx = @{
    RepoRoot       = $RepoRoot
    WindowsDir     = $WindowsDir
    HomeManagerDir = Join-Path $RepoRoot 'home-manager'
    ConfigsDir     = Join-Path $RepoRoot 'configs'
    HostName       = $HostName
    HostFile       = $HostFile
}

$Links   = & (Join-Path $WindowsDir 'links.ps1') $Ctx
$HostCfg = & $HostFile
$modules = @($HostCfg.Modules)

Write-Banner "$HostName  -  $($modules.Count) module(s)"

$ok = 0; $fail = 0
foreach ($modName in $modules) {
    Update-Path  # pick up tools installed by previous modules
    Write-Section $modName
    try {
        if ($Links.ContainsKey($modName)) {
            Invoke-Symlinks $Links[$modName]
            $ok++; continue
        }

        $modPath = Join-Path $WindowsDir ("modules\" + ($modName -replace '\.', '\') + "\module.ps1")
        if (-not (Test-Path $modPath)) {
            Write-Fail "$modName -> not in links.ps1, no module file"
            $fail++; continue
        }
        $mod = & $modPath
        if (-not $mod.Apply) { Write-Warn "no Apply block"; continue }
        & $mod.Apply $Ctx
        $ok++
    } catch {
        Write-Fail "$modName -> $_"
        $fail++
    }
}

Write-Banner "Done: $ok ok, $fail failed"

if (-not $env:CI -and -not $env:SSH_CLIENT -and -not $env:SSH_CONNECTION) {
    Read-Host "Press Enter to exit" | Out-Null
}
