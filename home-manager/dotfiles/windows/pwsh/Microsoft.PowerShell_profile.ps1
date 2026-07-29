$env:SHELL = "pwsh"

$Ps1d = Join-Path $PSScriptRoot 'ps1.d'

# Is this a real shell, or `pwsh -c ...` / `pwsh -File ...`? SSH runs everything --
# including the sftp subsystem behind scp -- through `pwsh -c`, so anything only a human
# needs is pure overhead there. Not exhaustive (pwsh accepts abbreviations), but it covers
# every launcher that actually starts a shell here: sshd, Windows Terminal, VS Code.
# A plain foreach, not a Where-Object pipeline: the pipeline version measured 43 ms, which
# every scp would have paid, and this runs before anything else can be skipped.
$Interactive = $true
foreach ($arg in [Environment]::GetCommandLineArgs()) {
    if ($arg -match '^-(c|command|f|file|e|encodedcommand|noninteractive)$') {
        $Interactive = $false
        break
    }
}

# Tools that print their own bootstrap script (oh-my-posh, zoxide, gh) produce the same
# output until the tool itself is upgraded, so generate it once and dot-source the result
# afterwards. `oh-my-posh init pwsh` in particular only emits a 260-byte wrapper that turns
# around and runs oh-my-posh a second time for the real 60 KB script; caching the 60 KB
# directly measured 94-105 ms against 227-241 ms for the round trip.
$InitCache = Join-Path $env:LOCALAPPDATA 'pwsh-init-cache'

function Import-CachedInit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Command,
        [Parameter(Mandatory)][scriptblock]$Generate
    )

    $exe = Get-Command $Command -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if (-not $exe) { return }

    # Rebuild when the binary changes; its write time is enough to catch upgrades.
    $stamp   = "{0}|{1}" -f $exe.Source, (Get-Item $exe.Source).LastWriteTimeUtc.Ticks
    $script  = Join-Path $InitCache "$Name.ps1"
    $stampAt = Join-Path $InitCache "$Name.stamp"

    if (-not (Test-Path $script) -or
        -not (Test-Path $stampAt) -or
        (Get-Content $stampAt -Raw -ErrorAction SilentlyContinue).Trim() -ne $stamp) {

        if (-not (Test-Path $InitCache)) { New-Item -ItemType Directory -Path $InitCache -Force | Out-Null }
        try {
            & $Generate | Out-String | Set-Content -Path $script -Encoding UTF8
            Set-Content -Path $stampAt -Value $stamp -Encoding UTF8
        } catch {
            Write-Warning "init cache for $Name failed: $_"
            return
        }
    }

    . $script
}

# ---- always on: plain definitions, cheap enough to matter to scripts too ----
foreach ($file in 'env.ps1', 'alias.ps1', 'functions.ps1') {
    $path = Join-Path $Ps1d $file
    if (Test-Path $path) { . $path }
}

if (-not $Interactive) { return }

# ---- interactive only ----
Import-CachedInit -Name 'zoxide' -Command 'zoxide' -Generate { zoxide init powershell }
Import-CachedInit -Name 'oh-my-posh' -Command 'oh-my-posh' -Generate {
    oh-my-posh init pwsh --config (Join-Path $Ps1d 'theme.json') --print
}

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# ---- deferred: everything the first prompt does not need ----
# Terminal-Icons only changes how Get-ChildItem renders, PSFzf only binds Ctrl+T/Ctrl+R and
# posh-git only adds `git` argument completion (oh-my-posh already draws the git status), so
# none of them has to be ready before the prompt appears. Loading them on the first idle
# moment takes ~1.6s off every shell start; they are in place before a command can be typed.
#
# -Global is load-bearing. An event action runs in its own scope, so a plain Import-Module
# there loads the module into a scope that is discarded the moment the action returns: the
# module never reaches the session, and `ls` silently loses its icons while Ctrl+R stays on
# PSReadLine's own ReverseSearchHistory. Verified both ways on this machine.
$deferred = {
    Import-Module Terminal-Icons -Global -ErrorAction SilentlyContinue

    if (Get-Module -ListAvailable -Name PSFzf) {
        Import-Module PSFzf -Global -ErrorAction SilentlyContinue
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    }

    $completions = Join-Path $Ps1d 'completions.ps1'
    if (Test-Path $completions) { . $completions }
}.GetNewClosure()

# -MaxTriggerCount 1 so this fires once and unregisters itself.
Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action $deferred | Out-Null
