# Windows Service Module Idempotency Design

## Purpose

The Windows service modules currently enforce their desired state, but some of
them write configuration again on every `windows/apply.ps1` run. A second
apply with unchanged inputs should report already-correct service resources as
skipped while an apply after drift should still repair the managed state.

## Scope

Update the three modules under `windows/modules/services/`:

- `services.ahk` and `services.syncthing` manage their scheduled tasks.
- `services.sshd` manages OpenSSH capabilities, the `sshd` and `ssh-agent`
  service states, and the inbound TCP port 22 firewall rule.

The change will not compare entire scheduled-task XML definitions or manage
properties that the current modules do not declare.

## Design

Scheduled-task modules will build the same desired task definition as today,
then read any existing task with `Get-ScheduledTask`. They will compare only
the stable properties owned by each module: action executable and arguments,
logon trigger, principal identity and run level, and declared settings. When
those properties already match, the module writes `SKIP` and leaves the task
untouched. When the task is absent or any owned property differs, it retains
the existing `Register-ScheduledTask -Force` behavior to create or repair the
task.

The OpenSSH module already skips installed capabilities. It will additionally
inspect service startup and running states before calling `Set-Service`,
`Start-Service`, or `Stop-Service`. It will inspect the named firewall rule
and its associated port filter, writing `SKIP` when the rule already permits
enabled inbound TCP port 22 traffic and updating only when the owned rule
properties differ.

This is preferred over skipping solely because a named resource exists: a
stale executable path, changed user, disabled firewall rule, or changed port
must be repaired on the next apply.

## Error Handling

Missing applications or an AHK script remain warnings with no task update, as
they are today. Cmdlet failures while reading or repairing existing service
resources continue to flow to the runner, which reports the module as failed.

## Verification

Tests will exercise module behavior with PowerShell mocks rather than changing
live Windows resources:

- An already-matching scheduled task is skipped without registration.
- A missing or drifted scheduled task is registered with the desired state.
- Correct service and firewall state is skipped without mutation.
- Drifted OpenSSH service or firewall state invokes the required repair.

All modified PowerShell scripts will also receive a parser validation pass.
