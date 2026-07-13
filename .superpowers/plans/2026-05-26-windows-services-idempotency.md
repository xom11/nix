# Windows Service Module Idempotency Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make repeated Windows service-module applies skip already-correct scheduled tasks, OpenSSH services, and the SSH firewall rule while continuing to repair managed drift.

**Architecture:** Keep each service module self-contained. Scheduled-task modules construct their desired definition and compare the owned, stable properties of any existing task before registering it; the OpenSSH module similarly guards service and firewall mutations using their current state. Pester behavior tests use mocks so verification does not change system configuration.

**Tech Stack:** Windows PowerShell, ScheduledTasks, NetSecurity, Windows services, Pester 3-compatible tests

---

## File Structure

- Create: `windows/tests/scheduledTasks.Tests.ps1` - exercise `services.ahk` and `services.syncthing` no-op and drift-repair behavior with mocks.
- Modify: `windows/modules/services/ahk/module.ps1` - skip registration when the managed AHK task definition matches.
- Modify: `windows/modules/services/syncthing/module.ps1` - skip registration when the managed Syncthing task definition matches.
- Modify: `windows/tests/sshd.Tests.ps1` - retain the structural contract and add behavior checks for no-op and repair paths.
- Modify: `windows/modules/services/sshd/module.ps1` - conditionally mutate service and firewall properties.

### Task 1: Scheduled Task State Comparison

**Files:**
- Create: `windows/tests/scheduledTasks.Tests.ps1`
- Modify: `windows/modules/services/ahk/module.ps1`
- Modify: `windows/modules/services/syncthing/module.ps1`

- [ ] **Step 1: Write failing scheduled-task behavior tests**

Create tests that obtain each module hashtable with `& $ModulePath`, invoke its
`Apply` script block under mocked task cmdlets, and make these assertions:

```powershell
It 'does not register an already matching AHK task' {
    Mock Get-ScheduledTask { New-AhkTask -Execute $script:AhkExe }

    $module = & $AhkModulePath
    & $module.Apply $script:Ctx

    Assert-MockCalled Register-ScheduledTask 0 -Exactly
    Assert-MockCalled Write-Skip 1 -Exactly -ParameterFilter { $Msg -like 'scheduled task: AHKrunning*' }
}

It 'repairs an AHK task whose action has drifted' {
    Mock Get-ScheduledTask { New-AhkTask -Execute 'C:\stale\AutoHotkey.exe' }

    $module = & $AhkModulePath
    & $module.Apply $script:Ctx

    Assert-MockCalled Register-ScheduledTask 1 -Exactly -ParameterFilter { $TaskName -eq 'AHKrunning' -and $Force }
}

It 'does not register an already matching Syncthing task' {
    Mock Get-ScheduledTask { New-SyncthingTask -Execute $script:SyncthingExe }

    $module = & $SyncthingModulePath
    & $module.Apply $script:Ctx

    Assert-MockCalled Register-ScheduledTask 0 -Exactly
    Assert-MockCalled Write-Skip 1 -Exactly -ParameterFilter { $Msg -like 'scheduled task: Syncthing*' }
}

It 'repairs a Syncthing task whose action has drifted' {
    Mock Get-ScheduledTask { New-SyncthingTask -Execute 'C:\stale\syncthing.exe' }

    $module = & $SyncthingModulePath
    & $module.Apply $script:Ctx

    Assert-MockCalled Register-ScheduledTask 1 -Exactly -ParameterFilter { $TaskName -eq 'Syncthing' -and $Force }
}
```

The fixture constructors return objects whose `Actions`, `Triggers`,
`Principal`, and `Settings` values match the values returned by mocks for
`New-ScheduledTaskAction`, `New-ScheduledTaskTrigger`,
`New-ScheduledTaskPrincipal`, and `New-ScheduledTaskSettingsSet`.

- [ ] **Step 2: Run the scheduled-task tests to verify RED**

Run on Windows PowerShell with Pester:

```powershell
Invoke-Pester -Script .\windows\tests\scheduledTasks.Tests.ps1 -Verbose -EnableExit
```

Expected: the matching-state assertions fail because both current modules
still call `Register-ScheduledTask -Force` on every apply.

- [ ] **Step 3: Implement minimal AHK comparison**

After constructing `$action`, `$trigger`, `$principal`, and `$settings`, read
the existing task and compare only managed properties:

```powershell
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
$taskMatches = $existingTask -and
    @($existingTask.Actions).Count -eq 1 -and
    $existingTask.Actions[0].Execute -eq $action.Execute -and
    $existingTask.Actions[0].Arguments -eq $action.Arguments -and
    @($existingTask.Triggers).Count -eq 1 -and
    $existingTask.Triggers[0].CimClass.CimClassName -eq $trigger.CimClass.CimClassName -and
    $existingTask.Triggers[0].UserId -eq $trigger.UserId -and
    $existingTask.Principal.UserId -eq $principal.UserId -and
    $existingTask.Principal.LogonType -eq $principal.LogonType -and
    $existingTask.Principal.RunLevel -eq $principal.RunLevel -and
    $existingTask.Settings.Enabled -eq $settings.Enabled -and
    $existingTask.Settings.DisallowStartIfOnBatteries -eq $settings.DisallowStartIfOnBatteries -and
    $existingTask.Settings.StopIfGoingOnBatteries -eq $settings.StopIfGoingOnBatteries -and
    $existingTask.Settings.StartWhenAvailable -eq $settings.StartWhenAvailable
if ($taskMatches) {
    Write-Skip "scheduled task: $taskName ($ahkExe)"
    return
}
```

Leave the existing registration command in place for absent or drifted tasks.

- [ ] **Step 4: Implement minimal Syncthing comparison**

Use the full current Windows identity for both its desired principal and logon
trigger, then compare the managed fields, including its declared retry and
time-limit settings:

```powershell
$userId    = [Security.Principal.WindowsIdentity]::GetCurrent().Name
$trigger   = New-ScheduledTaskTrigger -AtLogOn -User $userId
$principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
$taskMatches = $existingTask -and
    @($existingTask.Actions).Count -eq 1 -and
    $existingTask.Actions[0].Execute -eq $action.Execute -and
    $existingTask.Actions[0].Arguments -eq $action.Arguments -and
    @($existingTask.Triggers).Count -eq 1 -and
    $existingTask.Triggers[0].CimClass.CimClassName -eq $trigger.CimClass.CimClassName -and
    $existingTask.Triggers[0].UserId -eq $trigger.UserId -and
    $existingTask.Principal.UserId -eq $principal.UserId -and
    $existingTask.Principal.LogonType -eq $principal.LogonType -and
    $existingTask.Principal.RunLevel -eq $principal.RunLevel -and
    $existingTask.Settings.Enabled -eq $settings.Enabled -and
    $existingTask.Settings.DisallowStartIfOnBatteries -eq $settings.DisallowStartIfOnBatteries -and
    $existingTask.Settings.StopIfGoingOnBatteries -eq $settings.StopIfGoingOnBatteries -and
    $existingTask.Settings.ExecutionTimeLimit -eq $settings.ExecutionTimeLimit -and
    $existingTask.Settings.RestartCount -eq $settings.RestartCount -and
    $existingTask.Settings.RestartInterval -eq $settings.RestartInterval -and
    $existingTask.Description -eq 'Run Syncthing continuously in background'
if ($taskMatches) {
    Write-Skip "scheduled task: $taskName ($syncthingExe)"
    return
}
```

- [ ] **Step 5: Run scheduled-task tests to verify GREEN**

Run:

```powershell
Invoke-Pester -Script .\windows\tests\scheduledTasks.Tests.ps1 -Verbose -EnableExit
```

Expected: all four scheduled-task behavior tests pass.

- [ ] **Step 6: Commit scheduled-task behavior**

```bash
git add -- windows/tests/scheduledTasks.Tests.ps1 windows/modules/services/ahk/module.ps1 windows/modules/services/syncthing/module.ps1
git commit -m "feat(windows): skip unchanged scheduled service tasks"
```

### Task 2: OpenSSH Service And Firewall Comparison

**Files:**
- Modify: `windows/tests/sshd.Tests.ps1`
- Modify: `windows/modules/services/sshd/module.ps1`

- [ ] **Step 1: Write failing OpenSSH behavior tests**

Replace structural expectations that require unconditional mutation and add
mocked execution checks:

```powershell
It 'skips correct service and firewall state without mutation' {
    Mock Get-WindowsCapability { [pscustomobject]@{ State = 'Installed' } }
    Mock Get-Service {
        if ($Name -eq 'sshd') { [pscustomobject]@{ StartType = 'Automatic'; Status = 'Running' } }
        else { [pscustomobject]@{ StartType = 'Disabled'; Status = 'Stopped' } }
    }
    Mock Get-NetFirewallRule {
        [pscustomobject]@{ Enabled = 'True'; Direction = 'Inbound'; Action = 'Allow' }
    }
    Mock Get-NetFirewallPortFilter {
        [pscustomobject]@{ Protocol = 'TCP'; LocalPort = '22' }
    }

    $module = & $ModulePath
    & $module.Apply @{}

    Assert-MockCalled Set-Service 0 -Exactly
    Assert-MockCalled Start-Service 0 -Exactly
    Assert-MockCalled Stop-Service 0 -Exactly
    Assert-MockCalled Set-NetFirewallRule 0 -Exactly
    Assert-MockCalled Set-NetFirewallPortFilter 0 -Exactly
}

It 'repairs drifted service and firewall state' {
    Mock Get-WindowsCapability { [pscustomobject]@{ State = 'Installed' } }
    Mock Get-Service {
        if ($Name -eq 'sshd') { [pscustomobject]@{ StartType = 'Manual'; Status = 'Stopped' } }
        else { [pscustomobject]@{ StartType = 'Automatic'; Status = 'Running' } }
    }
    Mock Get-NetFirewallRule {
        [pscustomobject]@{ Enabled = 'False'; Direction = 'Inbound'; Action = 'Allow' }
    }
    Mock Get-NetFirewallPortFilter {
        [pscustomobject]@{ Protocol = 'TCP'; LocalPort = '2222' }
    }

    $module = & $ModulePath
    & $module.Apply @{}

    Assert-MockCalled Set-Service 1 -Exactly -ParameterFilter { $Name -eq 'sshd' -and $StartupType -eq 'Automatic' }
    Assert-MockCalled Start-Service 1 -Exactly -ParameterFilter { $Name -eq 'sshd' }
    Assert-MockCalled Set-Service 1 -Exactly -ParameterFilter { $Name -eq 'ssh-agent' -and $StartupType -eq 'Disabled' }
    Assert-MockCalled Stop-Service 1 -Exactly -ParameterFilter { $Name -eq 'ssh-agent' }
    Assert-MockCalled Set-NetFirewallRule 1 -Exactly
    Assert-MockCalled Set-NetFirewallPortFilter 1 -Exactly
}
```

- [ ] **Step 2: Run the OpenSSH tests to verify RED**

Run:

```powershell
Invoke-Pester -Script .\windows\tests\sshd.Tests.ps1 -Verbose -EnableExit
```

Expected: no-op test fails because the current module unconditionally calls
`Set-Service` and modifies an existing firewall rule.

- [ ] **Step 3: Guard service mutations**

Read each service once and only mutate incorrect fields:

```powershell
$sshd = Get-Service -Name sshd
$sshdChanged = $false
if ($sshd.StartType -ne 'Automatic') {
    Set-Service -Name sshd -StartupType Automatic
    $sshdChanged = $true
}
if ($sshd.Status -ne 'Running') {
    Start-Service -Name sshd
    $sshdChanged = $true
}
if ($sshdChanged) { Write-OK 'service: sshd (Automatic, Running)' }
else { Write-Skip 'service: sshd (Automatic, Running)' }
```

Apply the equivalent logic for `ssh-agent`, targeting `Disabled` and
`Stopped`.

- [ ] **Step 4: Guard firewall mutation**

Retrieve the associated port filter once and modify the rule only when one of
the managed values is wrong:

```powershell
if (-not $firewallRule) {
    New-NetFirewallRule -Name $firewallRuleName -DisplayName 'OpenSSH Server (sshd)' `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
    Write-OK 'firewall: inbound TCP 22 (OpenSSH-Server-In-TCP)'
} else {
    $portFilter = $firewallRule | Get-NetFirewallPortFilter
    $firewallMatches = "$($firewallRule.Enabled)" -eq 'True' -and
        "$($firewallRule.Direction)" -eq 'Inbound' -and
        "$($firewallRule.Action)" -eq 'Allow' -and
        "$($portFilter.Protocol)" -eq 'TCP' -and
        "$($portFilter.LocalPort)" -eq '22'
    if ($firewallMatches) {
        Write-Skip 'firewall: inbound TCP 22 (OpenSSH-Server-In-TCP)'
    } else {
        Set-NetFirewallRule -Name $firewallRuleName -Enabled True -Direction Inbound -Action Allow
        $portFilter | Set-NetFirewallPortFilter -Protocol TCP -LocalPort 22
        Write-OK 'firewall: inbound TCP 22 (OpenSSH-Server-In-TCP)'
    }
}
```

- [ ] **Step 5: Run OpenSSH tests to verify GREEN**

Run:

```powershell
Invoke-Pester -Script .\windows\tests\sshd.Tests.ps1 -Verbose -EnableExit
```

Expected: structural and mocked behavioral OpenSSH tests pass.

- [ ] **Step 6: Commit OpenSSH behavior**

```bash
git add -- windows/tests/sshd.Tests.ps1 windows/modules/services/sshd/module.ps1
git commit -m "feat(windows): skip unchanged OpenSSH service state"
```

### Task 3: Verify The Service Idempotency Change

**Files:**
- Verify: `windows/modules/services/ahk/module.ps1`
- Verify: `windows/modules/services/syncthing/module.ps1`
- Verify: `windows/modules/services/sshd/module.ps1`
- Verify: `windows/tests/scheduledTasks.Tests.ps1`
- Verify: `windows/tests/sshd.Tests.ps1`

- [ ] **Step 1: Run all non-invasive Windows Pester tests**

Run on Windows:

```powershell
Invoke-Pester -Script .\windows\tests -Verbose -EnableExit
```

Expected: all apply, scheduled-task, and OpenSSH tests pass with zero failed
tests.

- [ ] **Step 2: Parse all modified PowerShell scripts**

Run:

```powershell
$files = @(
    '.\windows\modules\services\ahk\module.ps1'
    '.\windows\modules\services\syncthing\module.ps1'
    '.\windows\modules\services\sshd\module.ps1'
    '.\windows\tests\scheduledTasks.Tests.ps1'
    '.\windows\tests\sshd.Tests.ps1'
)
$errors = @()
foreach ($file in $files) {
    $tokens = $null
    $fileErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile(
        (Resolve-Path $file).Path,
        [ref]$tokens,
        [ref]$fileErrors
    ) | Out-Null
    $errors += $fileErrors
}
if ($errors.Count -gt 0) {
    $errors | Format-List
    exit 1
}
```

Expected: exit code `0` with no parser errors.

- [ ] **Step 3: Review scope and status**

Run:

```bash
git status --short --branch
git diff --stat origin/main..HEAD
git log --oneline --max-count=5
```

Expected: only the idempotency spec, plan, three service modules, and their
tests are included in this feature's commits.
