Describe 'windows services.ahk-watchdog module' {
    BeforeAll {
        $RepoRoot   = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ModulePath = Join-Path $RepoRoot 'windows\modules\services\ahk-watchdog\module.ps1'
        $ModuleText = Get-Content -Raw -LiteralPath $ModulePath
        $AhkText    = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\modules\services\ahk\module.ps1')
        $LaunchText = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\launch-ahk.ahk')
        $MainText   = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\main.ahk')
        $ApplyText  = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\apply.ps1')

        Import-Module (Join-Path $RepoRoot 'windows\lib\ScheduledTask.psm1') -Force

        function Write-OK { param($Msg) }
        function Write-Skip { param($Msg) }
        function Write-Warn { param($Msg) }
    }

    It 'does not hang the watchdog repetition off the resident AHK task' {
        # This is the whole reason the watchdog moved out of services.ahk. Reload() -- Tab+r,
        # tab-key.ahk -- makes the running process exit 0 and spawn a replacement that Task
        # Scheduler does not own, so the AHKrunning instance is marked completed the instant the
        # script reloads. MultipleInstances=IgnoreNew then protects nothing, and the next repeat
        # launches a second main.ahk whose #SingleInstance Force kills the freshly reloaded one.
        # Observed twice on a14 (30/07/2026): `reason=Reload` in ahk-main.log, then id=201
        # "successfully completed", then `reason=Single` at the following 5-minute tick.
        $AhkText | Should Not Match 'RepetitionInterval'
        $AhkText | Should Not Match 'MSFT_TaskTimeTrigger'
        $AhkText | Should Not Match 'watchdogTrigger'
    }

    It 'asks the launcher to leave a healthy main.ahk alone' {
        $ModuleText | Should Match 'launch-ahk\.ahk'
        $ModuleText | Should Match '--if-missing'
        $LaunchText | Should Match ([regex]::Escape('A_Args[1] = "--if-missing"'))
    }

    It 'decides liveness from the script window, not the process name' {
        # AutoHotkey64.exe is shared by launch-kanata.ahk, this launcher, and any script the
        # owner runs by hand, so ProcessExist would report main.ahk alive when it is not. The
        # per-script hidden main window is titled with the script's full path.
        $LaunchText | Should Match 'DetectHiddenWindows'
        $LaunchText | Should Match 'ahk_class AutoHotkey'
        # The call, not the word: the comment above it names ProcessExist to say why not.
        $LaunchText | Should Not Match 'ProcessExist\('
        # The window title is the script path plus " - AutoHotkey v2.0.26", so the match relies
        # on the default TitleMatchMode 2. Exact matching would never match, every tick would
        # conclude main.ahk is gone, and the watchdog would start a duplicate every five minutes.
        $LaunchText | Should Not Match 'SetTitleMatchMode\(\s*3'
    }

    It 'lets two invocations of the launcher coexist' {
        # The logon task may be starting main.ahk in the same second this runs; the v2 default
        # would have one invocation of the launcher kill the other mid-check.
        $LaunchText | Should Match '#SingleInstance Off'
        $LaunchText | Should Match 'Sleep\('
    }

    It 'revives the script unelevated, exactly as the logon task starts it' {
        # main.ahk must stay a limited process (see ahkPrivilege.Tests.ps1) and the script the
        # launcher starts inherits the launcher's level, so this task cannot run Highest.
        $ModuleText | Should Match 'RunLevel Limited'
        $ModuleText | Should Not Match 'RunLevel Highest'
        $MainText | Should Not Match '#Include launch-ahk\.ahk'
    }

    It 'arms a time trigger that does not wait for a logon' {
        $ModuleText | Should Match 'New-ScheduledTaskTrigger\s+-Once'
        $ModuleText | Should Match 'RepetitionInterval'
        # A moving anchor would re-register a task that was already correct on every apply run.
        $ModuleText | Should Not Match '-Once\s+-At\s+\(Get-Date\)'
        $ModuleText | Should Match '-ExecutionTimeLimit 0'
    }

    It 'is applied after services.ahk' {
        $ahk   = $ApplyText.IndexOf("'services.ahk'")
        $watch = $ApplyText.IndexOf("'services.ahk-watchdog'")
        ($ahk -ge 0) | Should Be $true
        ($watch -ge 0) | Should Be $true
        ($ahk -lt $watch) | Should Be $true
    }

    Context 'applying against existing state' {
        BeforeEach {
            $script:Ctx      = @{ HomeManagerDir = 'C:\home-manager' }
            $script:AhkExe   = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
            $script:Launcher = Join-Path $script:Ctx.HomeManagerDir 'dotfiles\windows\ahk\launch-ahk.ahk'
            $script:UserId   = [Security.Principal.WindowsIdentity]::GetCurrent().Name

            Mock Get-Command { [pscustomobject]@{ Source = $script:AhkExe } }
            Mock Test-Path { $true }
            Mock Register-ScheduledTask { }
            Mock Write-OK { }
            Mock Write-Skip { }
            Mock Write-Warn { }
        }

        function New-AhkWatchdogTask {
            param([string]$Arguments)
            [pscustomobject]@{
                Actions = @([pscustomobject]@{
                    Execute   = $script:AhkExe
                    Arguments = $Arguments
                })
                Triggers = @([pscustomobject]@{
                    CimClass   = [pscustomobject]@{ CimClassName = 'MSFT_TaskTimeTrigger' }
                    Repetition = [pscustomobject]@{ Interval = 'PT5M'; Duration = '' }
                })
                Principal = [pscustomobject]@{
                    UserId    = ($script:UserId -split '\\')[-1]
                    LogonType = 'Interactive'
                    RunLevel  = 'Limited'
                }
                Settings = [pscustomobject]@{
                    Enabled                    = $true
                    DisallowStartIfOnBatteries = $false
                    StopIfGoingOnBatteries     = $false
                    StartWhenAvailable         = $true
                    ExecutionTimeLimit         = 'PT0S'
                }
                Description = 'Start main.ahk when it is not running; leaves a healthy instance alone'
            }
        }

        It 'does not re-register a task that already matches' {
            Mock Get-ScheduledTask { New-AhkWatchdogTask -Arguments "`"$script:Launcher`" --if-missing" }

            $module = & $ModulePath
            & $module.Apply $script:Ctx

            Assert-MockCalled -CommandName Register-ScheduledTask -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Write-Skip -Times 1 -Exactly -Scope It -ParameterFilter {
                $Msg -like 'scheduled task: AHKWatchdog*'
            }
        }

        It 'repairs a watchdog that lost its --if-missing argument' {
            Mock Get-ScheduledTask { New-AhkWatchdogTask -Arguments "`"$script:Launcher`"" }

            $module = & $ModulePath
            & $module.Apply $script:Ctx

            Assert-MockCalled -CommandName Register-ScheduledTask -Times 1 -Exactly -Scope It -ParameterFilter {
                $TaskName -eq 'AHKWatchdog' -and $Force
            }
        }
    }
}
