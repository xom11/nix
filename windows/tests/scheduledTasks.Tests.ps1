Describe 'windows scheduled service task modules' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $AhkModulePath = Join-Path $RepoRoot 'windows\modules\services\ahk\module.ps1'

        # The modules compare principals through Test-TaskUserMatch; apply.ps1 imports this lib
        # before running them, so the tests have to provide it too.
        Import-Module (Join-Path $RepoRoot 'windows\lib\ScheduledTask.psm1') -Force

        function Write-OK { param($Msg) }
        function Write-Skip { param($Msg) }
        function Write-Warn { param($Msg) }

        function New-AhkTask {
            param([string]$Execute)
            [pscustomobject]@{
                Actions = @([pscustomobject]@{
                    Execute   = $Execute
                    Arguments = "`"$script:AhkFile`""
                })
                # Logon is the only trigger. Reviving a dead script belongs to the separate
                # AHKWatchdog task (see ahkWatchdog.Tests.ps1): a timed repeat here stopped
                # protecting anything the moment Reload() replaced the tracked process.
                Triggers = @(
                    [pscustomobject]@{
                        CimClass = [pscustomobject]@{ CimClassName = 'MSFT_TaskLogonTrigger' }
                        UserId   = $null
                        Delay    = 'PT15S'
                    }
                )
                Principal = [pscustomobject]@{
                    # Task Scheduler reads principals back without the domain part, which is
                    # exactly the drift Test-TaskUserMatch has to absorb.
                    UserId    = ($script:UserId -split '\\')[-1]
                    LogonType = 'Interactive'
                    RunLevel  = 'Limited'
                }
                Settings = [pscustomobject]@{
                    Enabled                       = $true
                    DisallowStartIfOnBatteries    = $false
                    StopIfGoingOnBatteries        = $false
                    StartWhenAvailable            = $true
                    MultipleInstances             = 'IgnoreNew'
                    ExecutionTimeLimit            = 'PT0S'
                }
            }
        }
    }

    Context 'AutoHotkey task' {
        BeforeEach {
            $script:Ctx = @{ HomeManagerDir = 'C:\home-manager' }
            $script:AhkExe = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
            $script:AhkFile = Join-Path $script:Ctx.HomeManagerDir 'dotfiles\windows\ahk\main.ahk'
            $script:UserId = [Security.Principal.WindowsIdentity]::GetCurrent().Name

            # Mocked on the shared helper, not on Get-Command: see kanataWatchdog.Tests.ps1.
            Mock Get-AutoHotkeyExe { $script:AhkExe }
            Mock Test-Path { $true }
            Mock Register-ScheduledTask { }
            Mock Write-OK { }
            Mock Write-Skip { }
            Mock Write-Warn { }
        }

        It 'does not register an already matching AHK task' {
            Mock Get-ScheduledTask { New-AhkTask -Execute $script:AhkExe }

            $module = & $AhkModulePath
            & $module.Apply $script:Ctx

            Assert-MockCalled -CommandName Register-ScheduledTask -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Write-Skip -Times 1 -Exactly -Scope It -ParameterFilter { $Msg -like 'scheduled task: AHKrunning*' }
        }

        It 'repairs an AHK task whose action has drifted' {
            Mock Get-ScheduledTask { New-AhkTask -Execute 'C:\stale\AutoHotkey.exe' }

            $module = & $AhkModulePath
            & $module.Apply $script:Ctx

            Assert-MockCalled -CommandName Register-ScheduledTask -Times 1 -Exactly -Scope It -ParameterFilter {
                $TaskName -eq 'AHKrunning' -and $Force
            }
        }
    }
}
