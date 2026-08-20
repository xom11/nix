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

function Get-AutoHotkeyExe {
    # Four service modules run an AutoHotkey script from a scheduled task, and each used to carry
    # its own copy of this lookup. Four copies of one decision is four chances to drift, which is
    # not hypothetical here -- windows-tests.yml exists because three assertions had already
    # drifted out of sync with the modules.
    #
    # Measured on a14 (2026-08-07): none of the three names resolve, AutoHotkey is not on PATH,
    # and every task on that machine is running the ProgramFiles path below. The PATH probe is
    # kept for a host that installs AutoHotkey some other way -- but it is kept ONCE.
    #
    # Returns $null when nothing is found; callers warn and return rather than registering a task
    # that points at nothing.
    [CmdletBinding()]
    param()

    foreach ($name in 'AutoHotkey64', 'AutoHotkey', 'AutoHotkey32') {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }

    @(
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe"
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey.exe"
        "$env:ProgramFiles\AutoHotkey\AutoHotkey.exe"
        "${env:ProgramFiles(x86)}\AutoHotkey\AutoHotkey.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
}

function Test-ScheduledTaskMatch {
    # Is the registered task already exactly what this apply run would create? Answering no
    # re-registers it; answering yes is what keeps `apply.ps1` idempotent and quiet.
    #
    # This is the union of the per-module comparisons it replaces, and deliberately compares
    # every property rather than only the ones a given module happens to set. MultipleInstances
    # was the one gap, found 20/08/2026 while costing out an on-demand task: no module sets it,
    # so nothing noticed -- but a task once registered without -MultipleInstances Parallel would
    # be reported Skip forever while silently dropping every start that overlapped a running
    # instance, with LastTaskResult stuck at 0 throughout. Measured before adding the compare:
    # both New-ScheduledTaskSettingsSet and Get-ScheduledTask report MultipleInstancesEnum and
    # agree after a [string] cast, so this does not re-register the existing six tasks. A property left
    # unset still has a value -- an omitted -RestartCount means 0, not "don't care" -- so
    # comparing it is how a task that used to carry one gets repaired after the module stops
    # asking for it. Skipping it instead would leave the stale value in place forever.
    #
    # Normalisation matters more than the comparisons: Task Scheduler reads several of these
    # back in a different shape than New-ScheduledTask* wrote them.
    #   - UserId       'DOMAIN\user' out, 'user' back -> compare SIDs (Resolve-TaskUserId)
    #   - Delay,       TimeSpan-ish out, ISO 8601 string back, $null when unset
    #     Repetition,  -> [string] casts both, and [string]$null is '' on either side
    #     Description
    #   - RestartCount $null on a task that never had one, 0 from the settings object
    #     -> [int] casts both, and [int]$null is 0
    #
    # StartBoundary is deliberately absent: it is given without a timezone and read back with
    # one, so comparing it would never match and every apply run would re-register.
    [CmdletBinding()]
    param(
        $Existing,
        $Action,
        $Trigger,
        $Principal,
        $Settings,
        [string]$Description
    )

    if (-not $Existing) { return $false }

    # Count -eq 1 on each is load-bearing, not a formality. It is what notices a machine still
    # running an older shape -- AHKrunning once carried a second, timed trigger, and the count is
    # the only thing that spots the leftover and re-registers the task without it.
    if (@($Existing.Actions).Count -ne 1)  { return $false }
    if (@($Existing.Triggers).Count -ne 1) { return $false }

    $ea = $Existing.Actions[0]
    if ($ea.Execute          -ne $Action.Execute)   { return $false }
    if ($ea.Arguments        -ne $Action.Arguments) { return $false }
    if ([string]$ea.WorkingDirectory -ne [string]$Action.WorkingDirectory) { return $false }

    $et = $Existing.Triggers[0]
    if ($et.CimClass.CimClassName -ne $Trigger.CimClass.CimClassName) { return $false }
    if (-not (Test-TaskUserMatch $et.UserId $Trigger.UserId))         { return $false }
    if ([string]$et.Delay -ne [string]$Trigger.Delay)                 { return $false }
    if ([string]$et.Repetition.Interval -ne [string]$Trigger.Repetition.Interval) { return $false }
    if ([string]$et.Repetition.Duration -ne [string]$Trigger.Repetition.Duration) { return $false }

    $ep = $Existing.Principal
    if (-not (Test-TaskUserMatch $ep.UserId $Principal.UserId)) { return $false }
    if ($ep.LogonType -ne $Principal.LogonType)                 { return $false }
    if ($ep.RunLevel  -ne $Principal.RunLevel)                  { return $false }

    # [bool] on the flags for the same reason [int] is on RestartCount: a settings object built
    # without -StartWhenAvailable reports $false, but a task object that never carried the flag
    # reports $null, and $null -eq $false is False. "Absent" and "off" are the same state here.
    $es = $Existing.Settings
    if ([bool]$es.Enabled                    -ne [bool]$Settings.Enabled)                    { return $false }
    if ([bool]$es.DisallowStartIfOnBatteries -ne [bool]$Settings.DisallowStartIfOnBatteries) { return $false }
    if ([bool]$es.StopIfGoingOnBatteries     -ne [bool]$Settings.StopIfGoingOnBatteries)     { return $false }
    if ([bool]$es.StartWhenAvailable         -ne [bool]$Settings.StartWhenAvailable)         { return $false }
    if ([string]$es.MultipleInstances        -ne [string]$Settings.MultipleInstances)        { return $false }
    if ($es.ExecutionTimeLimit               -ne $Settings.ExecutionTimeLimit)               { return $false }
    if ([int]$es.RestartCount                -ne [int]$Settings.RestartCount)                { return $false }
    if ([string]$es.RestartInterval          -ne [string]$Settings.RestartInterval)          { return $false }

    if ([string]$Existing.Description -ne $Description) { return $false }

    return $true
}

Export-ModuleMember -Function Resolve-TaskUserId, Test-TaskUserMatch, Get-AutoHotkeyExe, Test-ScheduledTaskMatch
