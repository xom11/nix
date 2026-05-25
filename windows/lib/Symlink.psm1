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
        }
        Remove-Item $Target -Force -Recurse
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
