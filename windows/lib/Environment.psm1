# The machine's tool environment: what CPU it really is, what is on PATH, and
# making sure scoop exists at all. Was Package.psm1 until the winget and scoop
# install paths became `dotpkg apply` (2026-08-12) and the name stopped fitting.
#
# Install-NpmPackages and Install-PSModules left on 2026-08-13: each had exactly
# one caller, so they live in that caller now.
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



Export-ModuleMember -Function Update-Path, Get-NativeArchitecture, Install-Scoop
