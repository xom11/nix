# Single Windows Apply Entry Point Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `windows/apply.ps1` apply the single Windows configuration directly without a per-host `windows.ps1` file.

**Architecture:** The Windows entry point becomes the owner of its ordered module list and keeps the existing module runner intact. A non-invasive Pester contract test checks script structure and removal of the obsolete host indirection without invoking system-changing modules.

**Tech Stack:** PowerShell 7, Pester 3.4-compatible assertions, Git

---

### Task 1: Contract Test For The Shared Entry Point

**Files:**
- Create: `windows/tests/apply.Tests.ps1`

- [ ] **Step 1: Write the failing structural contract test**

Create `windows/tests/apply.Tests.ps1`:

```powershell
Describe 'windows/apply.ps1 shared entry point' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ApplyText = Get-Content -LiteralPath (Join-Path $RepoRoot 'windows\apply.ps1') -Raw
        $ObsoleteHostFile = Join-Path $RepoRoot 'hosts\zenbook-a14\windows.ps1'
        $ExpectedModules = @(
            'packages.winget'
            'packages.scoop'
            'packages.psmodules'
            'packages.npm'
            'dotfiles.pwsh'
            'dotfiles.windows-terminal'
            'dotfiles.powertoys'
            'dotfiles.vscode'
            'dotfiles.terminal.wezterm'
            'dotfiles.ai.claude'
            'dotfiles.ai.codex'
            'dotfiles.ai.gemini'
            'dotfiles.ai.aichat'
            'programs.ssh'
            'programs.nvim'
            'programs.yazi'
            'services.ahk'
            'services.syncthing'
        )
    }

    It 'owns the single Windows module selection directly' {
        foreach ($module in $ExpectedModules) {
            $ApplyText | Should Match ([regex]::Escape("'$module'"))
        }
    }

    It 'has no host-specific configuration selection' {
        $ApplyText | Should Not Match '\$HostName'
        $ApplyText | Should Not Match '\$HostFile'
        $ApplyText | Should Not Match 'hosts[\\/].*windows\.ps1'
        (Test-Path -LiteralPath $ObsoleteHostFile) | Should Be $false
    }
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```powershell
Invoke-Pester -Script .\windows\tests\apply.Tests.ps1 -Verbose -EnableExit
```

Expected: `FAIL`, because `windows/apply.ps1` still resolves `$HostFile` and
the host configuration file still exists.

### Task 2: Consolidate Windows Module Selection

**Files:**
- Modify: `windows/apply.ps1`
- Delete: `hosts/zenbook-a14/windows.ps1`

- [ ] **Step 1: Move the module list into the entry point**

Replace the entry point parameters and add the ordered module array before
execution:

```powershell
[CmdletBinding()]
param(
    # Skip self-elevation (use when running over SSH where UAC prompt cannot show).
    # Caller must already be admin, otherwise the script errors out.
    [switch]$NoElevate
)

$ErrorActionPreference = 'Stop'

$modules = @(
    'packages.winget'
    'packages.scoop'
    'packages.psmodules'
    'packages.npm'
    'dotfiles.pwsh'
    'dotfiles.windows-terminal'
    'dotfiles.powertoys'
    'dotfiles.vscode'
    'dotfiles.terminal.wezterm'
    'dotfiles.ai.claude'
    'dotfiles.ai.codex'
    'dotfiles.ai.gemini'
    'dotfiles.ai.aichat'
    'programs.ssh'
    'programs.nvim'
    'programs.yazi'
    'services.ahk'
    'services.syncthing'
)
```

- [ ] **Step 2: Remove host selection and host-file loading**

Remove the `$HostName` parameter, elevated invocation argument, host-file
resolution/error branch, `HostName`/`HostFile` context entries, and execution
of the host configuration file. The central setup portion becomes:

```powershell
    Import-Module (Join-Path $WindowsDir 'lib\Logging.psm1') -Force
    Import-Module (Join-Path $WindowsDir 'lib\Symlink.psm1') -Force
    Import-Module (Join-Path $WindowsDir 'lib\Package.psm1') -Force

    $Ctx = @{
        RepoRoot       = $RepoRoot
        WindowsDir     = $WindowsDir
        HomeManagerDir = Join-Path $RepoRoot 'home-manager'
        ConfigsDir     = Join-Path $RepoRoot 'configs'
    }

    $Links = & (Join-Path $WindowsDir 'links.ps1') $Ctx

    Write-Banner "Windows  -  $($modules.Count) module(s)"
```

Iterate over the existing `$modules` variable using the existing loop body,
and reduce the elevated process argument list to:

```powershell
        Start-Process powershell.exe -Verb RunAs -ArgumentList @(
            '-NoProfile'
            '-ExecutionPolicy', 'Bypass'
            '-File', "`"$PSCommandPath`""
        )
```

- [ ] **Step 3: Delete the obsolete host configuration**

Delete `hosts/zenbook-a14/windows.ps1`; retain all other ZenBook host files.

- [ ] **Step 4: Run the Pester test to verify it passes**

Run:

```powershell
Invoke-Pester -Script .\windows\tests\apply.Tests.ps1 -Verbose -EnableExit
```

Expected: `PASS` with zero failed tests.

### Task 3: Final Verification

**Files:**
- Verify: `windows/apply.ps1`
- Verify: `windows/tests/apply.Tests.ps1`

- [ ] **Step 1: Parse changed PowerShell files**

Run:

```powershell
$files = '.\windows\apply.ps1', '.\windows\tests\apply.Tests.ps1'
foreach ($file in $files) {
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile(
        (Resolve-Path $file), [ref]$null, [ref]$errors)
    if ($errors) { throw ($errors | Out-String) }
}
```

Expected: exit code `0` with no parsing errors.

- [ ] **Step 2: Search for obsolete Windows host-entry references**

Run:

```powershell
rg -n 'HostFile|HostName|hosts[\\/].*windows\.ps1' windows hosts -g '!**/tests/**'
```

Expected: no matches in executable Windows script/config files.

- [ ] **Step 3: Commit the verified implementation**

Run:

```powershell
git add -- windows/apply.ps1 windows/tests/apply.Tests.ps1 hosts/zenbook-a14/windows.ps1
git commit -m "refactor(windows): remove per-host apply configuration"
```

Expected: one implementation commit containing the passing test, consolidated
entry point, and deletion of the obsolete host file.
