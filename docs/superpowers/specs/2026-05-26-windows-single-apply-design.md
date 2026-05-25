# Single Windows Apply Entry Point Design

## Purpose

Windows configuration currently requires `windows/apply.ps1` to locate
`hosts/<computer-name>/windows.ps1`, although the repository has only one
Windows configuration and the host file contains only the common module list.
The Windows entry point should apply that one configuration directly on any
Windows computer name.

## Design

`windows/apply.ps1` will own the ordered module list that is currently in
`hosts/zenbook-a14/windows.ps1`. It will retain the existing elevation,
module-loading, symlink and module-application behavior, but will no longer
accept a host-selection parameter or resolve a host-specific Windows script.

The execution context passed to modules will continue to expose repository and
Windows directory locations. `HostName` and `HostFile` will be removed because
no current module consumes them and they no longer describe the configuration
model.

`hosts/zenbook-a14/windows.ps1` will be deleted. The Linux documentation and
Nix definitions under `hosts/zenbook-a14` remain device-specific and are out of
scope.

## User Interface

The entry point remains:

```powershell
.\windows\apply.ps1
```

When elevation is needed, the script restarts itself without forwarding a host
argument. Its status banner describes the shared Windows configuration rather
than a host name.

## Verification

A Pester test will validate the structural contract without executing package
installation or scheduled-task changes:

- `windows/apply.ps1` declares the required module names directly.
- It no longer refers to `$HostName`, `$HostFile`, or host-local Windows
  configuration lookup.
- `hosts/zenbook-a14/windows.ps1` no longer exists.

PowerShell parsing and a reference search will supplement that test to catch
syntax errors and remaining references to the removed mechanism.
