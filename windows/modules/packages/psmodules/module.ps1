@{
    Description = 'PowerShell modules (Terminal-Icons, PSReadLine, PSFzf, posh-git)'
    Apply = {
        param($Ctx)
        # Every entry here is imported by the pwsh profile: Terminal-Icons and PSFzf in its
        # deferred block, posh-git from ps1.d/completions.ps1, PSReadLine in-box and configured
        # for MenuComplete. ZLocation used to be here and was not -- nothing in the repo ever
        # imported it, because the profile jumps directories with zoxide, which comes from
        # winget and caches its init script. Two jumpers, one of them never loaded.
        Install-PSModules @(
            'Terminal-Icons'
            'PSReadLine'
            'PSFzf'
            'posh-git'
        )
    }
}
