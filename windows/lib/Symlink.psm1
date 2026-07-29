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
        New-Item -ItemType SymbolicLink -Path $Target -Value $sourceResolved -Force | Out-Null
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
