# Windows OpenSSH Service Automation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the shared Windows apply script install and configure the built-in OpenSSH client/server setup with inbound SSH enabled and `ssh-agent` disabled.

**Architecture:** Add one focused `services.sshd` PowerShell module to the existing Windows module runner. The module idempotently manages optional capabilities, service states and the standard SSH firewall rule; structural Pester tests cover its contract without changing the live operating system during tests.

**Tech Stack:** PowerShell, Windows Optional Capabilities, Windows Services, Windows Defender Firewall, Pester 3

---

## File Structure

- Modify: `windows/apply.ps1` - select the new `services.sshd` module in the shared apply sequence.
- Modify: `windows/tests/apply.Tests.ps1` - require that the shared entry point selects `services.sshd`.
- Create: `windows/modules/services/sshd/module.ps1` - enforce OpenSSH capability, service and firewall state.
- Create: `windows/tests/sshd.Tests.ps1` - validate the service module contract without running system-changing commands.

### Task 1: Select The OpenSSH Service Module

**Files:**
- Modify: `windows/tests/apply.Tests.ps1`
- Modify: `windows/apply.ps1`

- [ ] **Step 1: Write the failing apply-selection test**

Add the new service module to `$ExpectedModules` in `windows/tests/apply.Tests.ps1`:

```powershell
            'services.ahk'
            'services.syncthing'
            'services.sshd'
```

- [ ] **Step 2: Run the apply-selection test to verify it fails**

Run:

```powershell
Invoke-Pester -Script .\windows\tests\apply.Tests.ps1 -Verbose -EnableExit
```

Expected: FAIL in `owns the single Windows module selection directly`, because `windows/apply.ps1` does not yet contain `'services.sshd'`.

- [ ] **Step 3: Add the selected module to the entry point**

Change the services block in `windows/apply.ps1` to:

```powershell
    # ---- services ----
    'services.ahk'
    'services.syncthing'
    'services.sshd'
```

- [ ] **Step 4: Run the apply-selection test to verify it passes**

Run:

```powershell
Invoke-Pester -Script .\windows\tests\apply.Tests.ps1 -Verbose -EnableExit
```

Expected: PASS with `2 Passed; 0 Failed`.

- [ ] **Step 5: Commit the module selection**

```powershell
git add -- windows/apply.ps1 windows/tests/apply.Tests.ps1
git commit -m "feat(windows): select OpenSSH service module"
```

### Task 2: Implement Idempotent OpenSSH Service State

**Files:**
- Create: `windows/tests/sshd.Tests.ps1`
- Create: `windows/modules/services/sshd/module.ps1`

- [ ] **Step 1: Write the failing service-module contract tests**

Create `windows/tests/sshd.Tests.ps1`:

```powershell
Describe 'windows services.sshd module' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ModulePath = Join-Path $RepoRoot 'windows\modules\services\sshd\module.ps1'
    }

    It 'exists as a selected OpenSSH service module' {
        (Test-Path -LiteralPath $ModulePath) | Should Be $true
    }

    Context 'when the module exists' {
        It 'installs the Windows OpenSSH capabilities' {
            $ModuleText = Get-Content -LiteralPath $ModulePath -Raw

            $ModuleText | Should Match ([regex]::Escape('OpenSSH.Client~~~~0.0.1.0'))
            $ModuleText | Should Match ([regex]::Escape('OpenSSH.Server~~~~0.0.1.0'))
            $ModuleText | Should Match 'Get-WindowsCapability'
            $ModuleText | Should Match 'Add-WindowsCapability'
        }

        It 'enables the SSH server and disables the key agent' {
            $ModuleText = Get-Content -LiteralPath $ModulePath -Raw

            $ModuleText | Should Match 'Set-Service\s+-Name\s+sshd\s+-StartupType\s+Automatic'
            $ModuleText | Should Match 'Start-Service\s+-Name\s+sshd'
            $ModuleText | Should Match 'Set-Service\s+-Name\s+ssh-agent\s+-StartupType\s+Disabled'
            $ModuleText | Should Match 'Stop-Service\s+-Name\s+ssh-agent'
        }

        It 'allows inbound TCP 22 without managing sshd_config' {
            $ModuleText = Get-Content -LiteralPath $ModulePath -Raw

            $ModuleText | Should Match ([regex]::Escape('OpenSSH-Server-In-TCP'))
            $ModuleText | Should Match 'New-NetFirewallRule'
            $ModuleText | Should Match 'Set-NetFirewallRule'
            $ModuleText | Should Match 'Set-NetFirewallPortFilter'
            $ModuleText | Should Not Match 'sshd_config'
        }
    }
}
```

- [ ] **Step 2: Run the service-module tests to verify they fail**

Run:

```powershell
Invoke-Pester -Script .\windows\tests\sshd.Tests.ps1 -Verbose -EnableExit
```

Expected: FAIL in `exists as a selected OpenSSH service module`, because `windows/modules/services/sshd/module.ps1` does not yet exist.

- [ ] **Step 3: Write the minimal OpenSSH service module**

Create `windows/modules/services/sshd/module.ps1`:

```powershell
@{
    Description = 'OpenSSH: built-in client/server, sshd service, and inbound firewall'
    Apply = {
        param($Ctx)

        foreach ($capabilityName in @(
            'OpenSSH.Client~~~~0.0.1.0'
            'OpenSSH.Server~~~~0.0.1.0'
        )) {
            $capability = Get-WindowsCapability -Online -Name $capabilityName
            if ($capability.State -eq 'Installed') {
                Write-Skip "capability: $capabilityName"
                continue
            }

            Write-Info "install capability: $capabilityName"
            Add-WindowsCapability -Online -Name $capabilityName | Out-Null
            Write-OK "capability: $capabilityName"
        }

        Set-Service -Name sshd -StartupType Automatic
        if ((Get-Service -Name sshd).Status -ne 'Running') {
            Start-Service -Name sshd
        }
        Write-OK 'service: sshd (Automatic, Running)'

        $firewallRuleName = 'OpenSSH-Server-In-TCP'
        $firewallRule = Get-NetFirewallRule -Name $firewallRuleName -ErrorAction SilentlyContinue
        if (-not $firewallRule) {
            New-NetFirewallRule -Name $firewallRuleName -DisplayName 'OpenSSH Server (sshd)' `
                -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
        } else {
            Set-NetFirewallRule -Name $firewallRuleName -Enabled True -Direction Inbound -Action Allow
            $firewallRule | Get-NetFirewallPortFilter |
                Set-NetFirewallPortFilter -Protocol TCP -LocalPort 22
        }
        Write-OK 'firewall: inbound TCP 22 (OpenSSH-Server-In-TCP)'

        Set-Service -Name ssh-agent -StartupType Disabled
        if ((Get-Service -Name ssh-agent).Status -ne 'Stopped') {
            Stop-Service -Name ssh-agent -Force
        }
        Write-OK 'service: ssh-agent (Disabled, Stopped)'
    }
}
```

- [ ] **Step 4: Run the service-module tests to verify they pass**

Run:

```powershell
Invoke-Pester -Script .\windows\tests\sshd.Tests.ps1 -Verbose -EnableExit
```

Expected: PASS with `4 Passed; 0 Failed`.

- [ ] **Step 5: Commit the OpenSSH module and tests**

```powershell
git add -- windows/modules/services/sshd/module.ps1 windows/tests/sshd.Tests.ps1
git commit -m "feat(windows): automate OpenSSH service setup"
```

### Task 3: Verify The Windows Configuration Change

**Files:**
- Verify: `windows/apply.ps1`
- Verify: `windows/tests/apply.Tests.ps1`
- Verify: `windows/modules/services/sshd/module.ps1`
- Verify: `windows/tests/sshd.Tests.ps1`

- [ ] **Step 1: Run all non-invasive Windows Pester tests**

Run:

```powershell
Invoke-Pester -Script .\windows\tests -Verbose -EnableExit
```

Expected: PASS with `6 Passed; 0 Failed`.

- [ ] **Step 2: Parse every changed PowerShell script**

Run:

```powershell
$files = @(
    '.\windows\apply.ps1'
    '.\windows\tests\apply.Tests.ps1'
    '.\windows\modules\services\sshd\module.ps1'
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

- [ ] **Step 3: Check the diff without modifying local user work**

Run:

```powershell
git status --short --branch
git diff --stat origin/main..HEAD
git diff -- windows/apply.ps1 windows/tests/apply.Tests.ps1 windows/modules/services/sshd/module.ps1 windows/tests/sshd.Tests.ps1
```

Expected: the committed feature files represent only OpenSSH automation; existing uncommitted changes in `home-manager/dotfiles/ai/codex.d/config.toml`, `home-manager/programs/ssh/config`, and `windows/links.ps1` remain untouched.

## Reference

- Microsoft Learn, "Get started with OpenSSH Server for Windows": `https://learn.microsoft.com/windows-server/administration/openssh/openssh_install_firstuse`
