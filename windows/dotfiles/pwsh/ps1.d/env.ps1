$dev="$env:USERPROFILE\documents\dev"
$tmp="$env:USERPROFILE\documents\tmp"
$nix="$env:USERPROFILE\.nix"

$env:CLAUDE_CODE_GIT_BASH_PATH = "C:\Users\kln\scoop\apps\git\current\bin\bash.exe"

$localBin = "$env:USERPROFILE\.local\bin"
if ($env:PATH -notlike "*$localBin*") {
    $env:PATH = "$localBin;$env:PATH"
}
