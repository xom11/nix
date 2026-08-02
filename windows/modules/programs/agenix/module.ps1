@{
    Description = 'Decrypt the shared apikey secret into %LOCALAPPDATA%\pwsh-secrets for pwsh'
    Apply = {
        param($Ctx)
        Import-Module (Join-Path $Ctx.WindowsDir 'lib\Secrets.psm1') -Force
        Update-PwshSecrets -RepoRoot $Ctx.RepoRoot | Out-Null
    }
}
