Describe 'windows services.kanata-watchdog module' {
    BeforeAll {
        $RepoRoot    = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $ModulePath  = Join-Path $RepoRoot 'windows\modules\services\kanata-watchdog\module.ps1'
        $ModuleText  = Get-Content -Raw -LiteralPath $ModulePath
        $KanataText  = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\modules\services\kanata\module.ps1')
        $LaunchText  = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\launch-kanata.ahk')
        $ApplyText   = Get-Content -Raw -LiteralPath (Join-Path $RepoRoot 'windows\apply.ps1')

        Import-Module (Join-Path $RepoRoot 'windows\lib\ScheduledTask.psm1') -Force

        function Write-OK { param($Msg) }
        function Write-Skip { param($Msg) }
        function Write-Warn { param($Msg) }
    }

    It 'asks the launcher to leave a healthy kanata alone' {
        $ModuleText | Should Match '--if-missing'
        # Killing a running kanata on a timer would drop keystrokes every few minutes.
        $LaunchText | Should Match ([regex]::Escape('A_Args[1] = "--if-missing"'))
        $LaunchText | Should Match 'ProcessExist\(KanataProc\)'
    }

    It 'keeps the force-restart path intact for evkey-monitor' {
        # evkey-monitor.ahk runs the Kanata task to re-register the WH_KEYBOARD_LL hook after
        # VKey restarts. That path must still kill and relaunch, so the two tasks cannot share
        # one action.
        $KanataText | Should Not Match '--if-missing'
        $LaunchText | Should Match 'ProcessClose\(KanataProc\)'
    }

    It 'arms a time trigger that does not wait for a logon' {
        $ModuleText | Should Match 'New-ScheduledTaskTrigger\s+-Once'
        $ModuleText | Should Match 'RepetitionInterval'
        $ModuleText | Should Not Match '-Once\s+-At\s+\(Get-Date\)'
        $ModuleText | Should Match 'RunLevel Highest'
    }

    It 'is applied after services.kanata' {
        $kanata = $ApplyText.IndexOf("'services.kanata'")
        $watch  = $ApplyText.IndexOf("'services.kanata-watchdog'")
        ($kanata -ge 0) | Should Be $true
        ($watch -ge 0) | Should Be $true
        ($kanata -lt $watch) | Should Be $true
    }

    Context 'applying against existing state' {
        BeforeEach {
            $script:Ctx = @{ HomeManagerDir = 'C:\home-manager' }
            $script:AhkExe = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
            $script:Launcher = Join-Path $script:Ctx.HomeManagerDir 'dotfiles\windows\ahk\launch-kanata.ahk'
            $script:UserId = [Security.Principal.WindowsIdentity]::GetCurrent().Name

            # The four AutoHotkey service modules resolve the interpreter through this one shared
            # helper (windows\lib\ScheduledTask.psm1), so the mock is on the helper rather than
            # on the Get-Command it happens to call. It also has to be: the helper lives inside a
            # module, and a plain Pester mock does not reach into a module's own scope.
            Mock Get-AutoHotkeyExe { $script:AhkExe }
            Mock Test-Path { $true }
            Mock Register-ScheduledTask { }
            Mock Write-OK { }
            Mock Write-Skip { }
            Mock Write-Warn { }
        }

        function New-WatchdogTask {
            param([string]$Arguments)
            [pscustomobject]@{
                Actions = @([pscustomobject]@{
                    Execute          = $script:AhkExe
                    Arguments        = $Arguments
                    WorkingDirectory = (Split-Path $script:Launcher -Parent)
                })
                Triggers = @([pscustomobject]@{
                    CimClass   = [pscustomobject]@{ CimClassName = 'MSFT_TaskTimeTrigger' }
                    Repetition = [pscustomobject]@{ Interval = 'PT5M'; Duration = '' }
                })
                Principal = [pscustomobject]@{
                    UserId    = ($script:UserId -split '\\')[-1]
                    LogonType = 'Interactive'
                    RunLevel  = 'Highest'
                }
                Settings = [pscustomobject]@{
                    Enabled                    = $true
                    DisallowStartIfOnBatteries = $false
                    StopIfGoingOnBatteries     = $false
                    StartWhenAvailable         = $true
                    ExecutionTimeLimit         = 'PT0S'
                }
                Description = 'Start Kanata when it is not running; leaves a healthy instance alone'
            }
        }

        It 'does not re-register a task that already matches' {
            Mock Get-ScheduledTask { New-WatchdogTask -Arguments "`"$script:Launcher`" --if-missing" }

            $module = & $ModulePath
            & $module.Apply $script:Ctx

            Assert-MockCalled -CommandName Register-ScheduledTask -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Write-Skip -Times 1 -Exactly -Scope It -ParameterFilter {
                $Msg -like 'scheduled task: KanataWatchdog*'
            }
        }

        It 'repairs a watchdog that lost its --if-missing argument' {
            Mock Get-ScheduledTask { New-WatchdogTask -Arguments "`"$script:Launcher`"" }

            $module = & $ModulePath
            & $module.Apply $script:Ctx

            Assert-MockCalled -CommandName Register-ScheduledTask -Times 1 -Exactly -Scope It -ParameterFilter {
                $TaskName -eq 'KanataWatchdog' -and $Force
            }
        }
    }
}
