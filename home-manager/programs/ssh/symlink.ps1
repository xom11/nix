$DotfileDir = "$env:USERPROFILE\.ssh"

"config" | ForEach-Object {
    $Src = Join-Path $PSScriptRoot $_
    $Dest = Join-Path $DotfileDir $_

    if (Test-Path $Src) {
        # Force remove existing file/link and create new Symbolic Link
        if (Test-Path $Dest) { Remove-Item $Dest -Force }
        New-Item -ItemType SymbolicLink -Path $Dest -Target $Src | Out-Null
        Write-Host "Linked: $_" -ForegroundColor Green
    } else {
        Write-Warning "Missing source: $Src"
    }
}