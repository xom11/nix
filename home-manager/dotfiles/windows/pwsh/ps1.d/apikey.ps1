# Nạp secret đã giải mã bởi windows/modules/programs/agenix.
#
# File này nằm trong repo public nên KHÔNG BAO GIỜ chứa giá trị -- nó chỉ
# dot-source file sinh ra ở %LOCALAPPDATA%. Máy chưa chạy apply.ps1 lần nào thì
# bỏ qua im lặng, giống `[ -r ... ] && source ...` trong .zshrc trên Unix.
$SecretsFile = Join-Path $env:LOCALAPPDATA 'pwsh-secrets\apikey.ps1'
if (Test-Path -LiteralPath $SecretsFile) { . $SecretsFile }
