function New-IdempotentSymlink {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Target
    )

    if (-not (Test-Path $Source)) {
        Write-Warn "source missing: $Source"
        return $false
    }
    $sourceResolved = (Resolve-Path $Source).Path

    $parent = Split-Path $Target -Parent
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        if ($item.LinkType -in 'SymbolicLink', 'Junction') {
            $existing = @($item.Target) | Select-Object -First 1
            if ($existing) {
                try {
                    $existingResolved = (Resolve-Path $existing -ErrorAction Stop).Path
                    if ($existingResolved -eq $sourceResolved) {
                        Write-Skip "$Target"
                        return $true
                    }
                } catch { }
            }
            # A link pointing somewhere else. The link holds no data of its own, so replacing
            # it costs nothing.
            Remove-Item $Target -Force -Recurse
        } else {
            # A real file or directory is sitting where the link belongs. This used to be
            # deleted outright by the same Remove-Item -Recurse, which would have taken real
            # config -- or a whole directory of it -- with it, with no copy kept. Move it aside
            # instead and let the caller decide what to do with it.
            $backup = "$Target.bak"
            $n = 1
            while (Test-Path $backup) {
                $backup = "$Target.bak$n"
                $n++
            }
            try {
                Move-Item -LiteralPath $Target -Destination $backup -Force -ErrorAction Stop
                Write-Warn "$Target existed as a real path - moved to $backup"
            } catch {
                Write-Fail "$Target is in the way and could not be moved aside: $_"
                return $false
            }
        }
    }

    try {
        # -ErrorAction Stop is load-bearing, and its absence was a silent lie.
        #
        # New-Item reports "Administrator privilege required for this operation"
        # as a NON-terminating error, so catch never fired: the function printed
        # OK and returned $true for a link it had not created. apply.ps1 sets
        # $ErrorActionPreference = 'Stop', but preference variables do not cross
        # a module boundary -- code in a .psm1 runs under the module's own scope,
        # which defaults to Continue. So the caller's Stop never applied here.
        #
        # Measured on a14 2026-08-12, in a non-elevated session with the caller
        # at Stop: returned True, printed OK, and Test-Path on the target was
        # False. Every link in that run reported green while nothing was linked.
        New-Item -ItemType SymbolicLink -Path $Target -Value $sourceResolved -Force -ErrorAction Stop | Out-Null
        Write-OK "$Target  ->  $sourceResolved"
        return $true
    } catch {
        Write-Fail "$Target : $_"
        return $false
    }
}

function Invoke-Symlinks {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][array]$Pairs
    )
    $ok = $true
    foreach ($p in $Pairs) {
        if (-not (New-IdempotentSymlink -Source $p.Source -Target $p.Target)) {
            $ok = $false
        }
    }
    return $ok
}

Export-ModuleMember -Function New-IdempotentSymlink, Invoke-Symlinks
