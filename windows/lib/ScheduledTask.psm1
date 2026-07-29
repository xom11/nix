function Resolve-TaskUserId {
    # Task Scheduler normalises principal account names on its own: New-ScheduledTaskPrincipal
    # keeps whatever it was given ('ZENBOOK-A14\kln'), while Get-ScheduledTask reads the task
    # back with the bare name ('kln'). Comparing those raw strings never matches, so every
    # apply run re-registered a task that was already correct. Compare resolved SIDs instead.
    [CmdletBinding()]
    param([string]$UserId)

    if ([string]::IsNullOrWhiteSpace($UserId)) { return '' }
    try {
        return ([Security.Principal.NTAccount]$UserId).Translate([Security.Principal.SecurityIdentifier]).Value
    } catch {
        # Unresolvable account (deleted user, other machine): fall back to the literal string
        # so the comparison degrades to the old behaviour rather than throwing.
        return $UserId
    }
}

function Test-TaskUserMatch {
    [CmdletBinding()]
    param([string]$Left, [string]$Right)

    (Resolve-TaskUserId $Left) -eq (Resolve-TaskUserId $Right)
}

Export-ModuleMember -Function Resolve-TaskUserId, Test-TaskUserMatch
