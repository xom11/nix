# Loads the secrets decrypted by windows/modules/programs/agenix.
#
# This file lives in a public repo, so it NEVER holds a value -- it only
# dot-sources the generated file under %LOCALAPPDATA%. A machine that has never
# run apply.ps1 skips it silently, like `[ -r ... ] && source ...` in .zshrc.
$SecretsFile = Join-Path $env:LOCALAPPDATA 'pwsh-secrets\apikey.ps1'
if (Test-Path -LiteralPath $SecretsFile) { . $SecretsFile }
