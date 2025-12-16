$SourceFile = ".\settings.json"
$SymlinkPath = "$env:HOME\settings.json"

New-Item -ItemType SymbolicLink -Path $SymlinkPath -Target $SourceFile