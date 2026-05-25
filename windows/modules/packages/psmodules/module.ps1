@{
    Description = 'PowerShell modules (Terminal-Icons, ZLocation, PSReadLine, PSFzf, posh-git)'
    Apply = {
        param($Ctx)
        Install-PSModules @(
            'Terminal-Icons'
            'ZLocation'
            'PSReadLine'
            'PSFzf'
            'posh-git'
        )
    }
}
