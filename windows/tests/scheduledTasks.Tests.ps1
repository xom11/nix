Describe 'windows scheduled service task modules' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $AhkModulePath = Join-Path $RepoRoot 'windows\modules\services\ahk\module.ps1'
        $SyncthingModulePath = Join-Path $RepoRoot 'windows\modules\services\syncthing\module.ps1'

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
                Triggers = @([pscustomobject]@{
                    CimClass = [pscustomobject]@{ CimClassName = 'MSFT_TaskLogonTrigger' }
                    UserId   = $null
                })
                Principal = [pscustomobject]@{
                    UserId    = $script:UserId
                    LogonType = 'Interactive'
                    RunLevel  = 'Limited'
                }
                Settings = [pscustomobject]@{
                    Enabled                       = $true
                    DisallowStartIfOnBatteries    = $false
                    StopIfGoingOnBatteries        = $false
                    StartWhenAvailable            = $true
                }
            }
        }

        function New-SyncthingTask {
            param([string]$Execute)
            [pscustomobject]@{
                Actions = @([pscustomobject]@{
                    Execute   = $Execute
                    Arguments = '--no-browser --no-console'
                })
                Triggers = @([pscustomobject]@{
                    CimClass = [pscustomobject]@{ CimClassName = 'MSFT_TaskLogonTrigger' }
                    UserId   = $script:UserId
                })
                Principal = [pscustomobject]@{
                    UserId    = $script:UserId
                    LogonType = 'Interactive'
                    RunLevel  = 'Limited'
                }
                Settings = [pscustomobject]@{
                    Enabled                       = $true
                    DisallowStartIfOnBatteries    = $false
                    StopIfGoingOnBatteries        = $false
                    ExecutionTimeLimit            = 'PT0S'
                    RestartCount                  = 3
                    RestartInterval               = 'PT1M'
                }
                Description = 'Run Syncthing continuously in background'
            }
        }
    }

    Context 'AutoHotkey task' {
        BeforeEach {
            $script:Ctx = @{ HomeManagerDir = 'C:\home-manager' }
            $script:AhkExe = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
            $script:AhkFile = Join-Path $script:Ctx.HomeManagerDir 'dotfiles\windows\ahk\main.ahk'
            $script:UserId = [Security.Principal.WindowsIdentity]::GetCurrent().Name

            Mock Get-Command { [pscustomobject]@{ Source = $script:AhkExe } }
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

    Context 'Syncthing task' {
        BeforeEach {
            $script:Ctx = @{}
            $script:SyncthingExe = 'C:\Program Files\Syncthing\syncthing.exe'
            $script:UserId = [Security.Principal.WindowsIdentity]::GetCurrent().Name

            Mock Get-Command { [pscustomobject]@{ Source = $script:SyncthingExe } }
            Mock Register-ScheduledTask { }
            Mock Write-OK { }
            Mock Write-Skip { }
            Mock Write-Warn { }
        }

        It 'does not register an already matching Syncthing task' {
            Mock Get-ScheduledTask { New-SyncthingTask -Execute $script:SyncthingExe }

            $module = & $SyncthingModulePath
            & $module.Apply $script:Ctx

            Assert-MockCalled -CommandName Register-ScheduledTask -Times 0 -Exactly -Scope It
            Assert-MockCalled -CommandName Write-Skip -Times 1 -Exactly -Scope It -ParameterFilter { $Msg -like 'scheduled task: Syncthing*' }
        }

        It 'repairs a Syncthing task whose action has drifted' {
            Mock Get-ScheduledTask { New-SyncthingTask -Execute 'C:\stale\syncthing.exe' }

            $module = & $SyncthingModulePath
            & $module.Apply $script:Ctx

            Assert-MockCalled -CommandName Register-ScheduledTask -Times 1 -Exactly -Scope It -ParameterFilter {
                $TaskName -eq 'Syncthing' -and $Force
            }
        }
    }
}
