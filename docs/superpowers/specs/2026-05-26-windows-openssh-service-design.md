# Windows OpenSSH Service Design

## Purpose

The Windows configuration should reproduce the manually established OpenSSH
server setup when `windows/apply.ps1` runs on a new or reset machine. The
configured machine must accept inbound SSH connections while keeping
`ssh-agent` disabled because outbound key-agent functionality is not required.

## Design

Add a `services.sshd` PowerShell module under
`windows/modules/services/sshd/module.ps1` and include it in the ordered
module list in `windows/apply.ps1`. Keeping the behavior in a service module
matches the existing Windows structure because it manages Windows services and
a firewall rule in addition to installing optional components.

The module runs within the already elevated Windows apply process and performs
idempotent state enforcement:

- Install Windows capabilities `OpenSSH.Client~~~~0.0.1.0` and
  `OpenSSH.Server~~~~0.0.1.0` only when either capability is not installed.
- Set the `sshd` service startup type to `Automatic` and start it when it is
  not running.
- Ensure an enabled inbound allow firewall rule named
  `OpenSSH-Server-In-TCP` exists for TCP port `22`.
- Set the `ssh-agent` service startup type to `Disabled` and stop it if it is
  running.

The module does not write `C:\ProgramData\ssh\sshd_config`, generate or copy
host keys, or manage user/admin authorized-key files. Windows OpenSSH owns its
default initialization, while existing user-specific SSH symlinks continue to
be managed by the current `programs.ssh` link entry.

## Error Handling

The module relies on the existing runner in `windows/apply.ps1`: a terminating
error while installing a capability or configuring a service/firewall rule is
reported as a failed module and causes the overall apply invocation to return
failure. Successful existing state should be reported as skipped or
successfully enforced rather than treated as an error.

## Verification

Pester tests will check the structural contract without installing Windows
capabilities or changing live services:

- `windows/apply.ps1` includes `services.sshd`.
- The new module references both OpenSSH capability identities, the `sshd`
  and `ssh-agent` services, and the `OpenSSH-Server-In-TCP` firewall rule.
- The module configures `sshd` as automatic, disables `ssh-agent`, and does
  not reference `sshd_config`.

A PowerShell parse check will validate syntax for the entry point, test file,
and service module.
