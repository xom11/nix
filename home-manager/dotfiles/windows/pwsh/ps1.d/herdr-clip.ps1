# Send-ClipImage -- push the Windows clipboard image into a Herdr session on
# whichever machine this box is currently ssh'd into, so an agent running there
# can read it.
#
# The gap this fills: `herdr --remote` already bridges a local clipboard image
# into the remote session -- and it ships on macOS and Linux (rog runs
# `herdr --remote macmini` today) -- but not on Windows ("Native Windows
# `herdr --remote` is not part of the beta"), and its clipboard-image reader is
# not wired there either. What works from Windows is `ssh <host>` and then
# `herdr` on that side, which leaves a screenshot taken here with no route in.
#
# This MUST run in the interactive desktop session, which is why the hotkey in
# herdr-clip.ahk exists rather than a shell function you call over ssh. Measured
# on a14: a process started by sshd reports SessionId 0 while explorer.exe sits
# in SessionId 1, and the two window stations own separate clipboards -- writing
# a marker string from the ssh session and reading it back returns that session's
# own clipboard, never the desktop's.
#
# HOW THE TARGET IS CHOSEN, and why it is not a constant any more.
#
# `herdr --remote <host>` never has this problem: the client process holds the
# connection, so the target is argv and a wrong guess is impossible. The shape we
# are stuck with on Windows throws that away -- you type the host into `ssh`, and
# nothing downstream remembers it. It cannot be recovered from the far end
# either: a Herdr server keeps no record of where a client came from (no
# client.list in its API, and the SSH_CLIENT a pane sees is a fossil from
# whatever shell started the server). The truth lives here, in the argv of the
# running ssh.exe -- so that is where it is read from, at the moment the key is
# pressed, with nothing remembered between presses.
#
# The parser below was validated against real `ps` output captured on airm3,
# 27/27 cases, including the ones that broke a naive version:
#   ssh -f -p 22 macmini ssh -o ... rog sleep 60   -> macmini, NOT rog. Everything
#                                                     after the host is a remote
#                                                     command, even another ssh.
#   ssh -F <path> -S <path> -T macmini exec ...    -> both flags eat a path
#   ssh: /Users/kln/.ssh/control-... [mux]         -> a process title, not an argv

# Options that consume the following token. Getting this list wrong is how a
# config path becomes a hostname.
$script:HerdrSshTakesArg = 'BbcDEeFIiJLlmOopQRSWw'

function Write-ClipImageLog {
    param([string]$Message)
    # Same shape as ahk-main.log: a hotkey that fails silently needs somewhere to
    # have said why, since nothing here has a console attached.
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    try { Add-Content -LiteralPath (Join-Path $env:LOCALAPPDATA 'herdr-clip.log') -Value $line } catch { }
}

function Split-CommandLine {
    param([string]$Line)
    # Enough of a splitter for a command line: quoted runs stay whole, everything
    # else breaks on whitespace. The exe path is the only part that is normally
    # quoted ("C:\Windows\System32\OpenSSH\ssh.exe" macmini).
    $out = [System.Collections.Generic.List[string]]::new()
    $cur = ''
    $inQuote = $false
    foreach ($ch in $Line.ToCharArray()) {
        if ($ch -eq '"') { $inQuote = -not $inQuote; continue }
        if (-not $inQuote -and ($ch -eq ' ' -or $ch -eq "`t")) {
            if ($cur) { $out.Add($cur); $cur = '' }
            continue
        }
        $cur += $ch
    }
    if ($cur) { $out.Add($cur) }
    return $out
}

function Get-SshTargetFromCommandLine {
    param([string]$CommandLine)

    if (-not $CommandLine) { return $null }
    # OpenSSH gives its ControlMaster processes a title instead of an argv. No
    # ControlMaster on Windows today, but the check is free and the parser is
    # shared with what was tested on macOS.
    if ($CommandLine.StartsWith('ssh: ') -or $CommandLine.TrimEnd().EndsWith('[mux]')) { return $null }
    # Herdr's own --remote plumbing is not a session the user opened. Cannot
    # occur on Windows; kept so the two platforms agree.
    if ($CommandLine -match 'remote-client-bridge' -or $CommandLine -match '[/\\]herdr-ssh-') { return $null }

    $argv = Split-CommandLine $CommandLine
    if ($argv.Count -lt 2) { return $null }

    # Split on both separators by hand rather than [IO.Path]::GetFileName*: that
    # one only knows the separator of the host it runs on, so on a Unix box it
    # reads "C:\Windows\System32\OpenSSH\ssh.exe" as one long file name. It would
    # have worked on Windows and been impossible to test anywhere else -- which is
    # how it got caught, running these cases under pwsh on macOS.
    $leaf = ($argv[0] -split '[\\/]')[-1]
    $exe = ($leaf -replace '(?i)\.exe$', '').ToLowerInvariant()
    if ($exe -ne 'ssh') { return $null }

    $i = 1
    while ($i -lt $argv.Count) {
        $tok = $argv[$i]
        if ($tok -eq '--') {
            return $(if ($i + 1 -lt $argv.Count) { $argv[$i + 1] } else { $null })
        }
        if ($tok.StartsWith('-') -and $tok.Length -gt 1) {
            # Bundled flags (-tf, -Nfp 2222) and inline values (-p2222): only the
            # LAST character can swallow the next token, and only when nothing
            # follows it inside this token.
            $body = $tok.Substring(1)
            $inlineValue = $false
            for ($k = 0; $k -lt $body.Length; $k++) {
                if ($script:HerdrSshTakesArg.Contains($body[$k])) {
                    if ($k -lt $body.Length - 1) { $inlineValue = $true }
                    break
                }
            }
            if (-not $inlineValue -and $script:HerdrSshTakesArg.Contains($body[$body.Length - 1])) {
                $i += 2
            } else {
                $i += 1
            }
            continue
        }
        # First non-option token is the destination. Everything after it belongs
        # to the remote command.
        return $tok
    }
    return $null
}

function Resolve-HerdrTarget {
    [CmdletBinding()]
    param()
    # Filtering on Name is what keeps ssh-agent, scp and sftp out; grepping the
    # string "ssh" would catch all three.
    #
    # And only this logon session's ssh, which is not paranoia: verifying this
    # function over ssh left an ssh.exe of its own in Session 0, and it showed up
    # as a candidate for a hotkey pressed on the desktop in Session 1. Anything
    # sshd spawns -- an agent doing remote work, a scheduled task -- would do the
    # same. The question the hotkey asks is "where is the terminal in front of
    # me connected", and that terminal is always in the caller's own session.
    $session = (Get-Process -Id $PID).SessionId
    $procs = @(Get-CimInstance Win32_Process -Filter "Name='ssh.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.SessionId -eq $session })
    $targets = foreach ($p in $procs) {
        $t = Get-SshTargetFromCommandLine $p.CommandLine
        if ($t) { $t }
    }
    # user@host and host are the same destination; dedupe on the host part but
    # hand back a form ssh accepts.
    $seen = @{}
    $unique = foreach ($t in $targets) {
        $alias = $t.Split('@')[-1]
        if (-not $seen.ContainsKey($alias)) { $seen[$alias] = $true; $t }
    }
    return @($unique)
}

function Save-ClipImageLocally {
    param([byte[]]$Bytes)
    # Written before anything can fail. Whatever else goes wrong -- no ssh
    # session, host asleep, Herdr dead -- the screenshot is never lost, because
    # by then the clipboard has usually moved on.
    $dir = Join-Path $env:USERPROFILE 'Pictures\herdr-clip'
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $path = Join-Path $dir ('{0}.png' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    [IO.File]::WriteAllBytes($path, $Bytes)
    Get-ChildItem -LiteralPath $dir -Filter '*.png' -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
        Remove-Item -Force -ErrorAction SilentlyContinue
    return $path
}

function Get-ClipImageBytes {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Snipping Tool, Chrome and Firefox all publish a real PNG under the "PNG"
    # clipboard format. Taking those bytes verbatim keeps the original encoding
    # and the alpha channel; Clipboard::GetImage() would round-trip through a DIB
    # and flatten transparency to black.
    $data = [Windows.Forms.Clipboard]::GetDataObject()
    if ($data -and $data.GetDataPresent('PNG')) {
        $stream = $data.GetData('PNG')
        if ($stream -is [IO.Stream]) {
            $ms = New-Object IO.MemoryStream
            $stream.Position = 0
            $stream.CopyTo($ms)
            $bytes = $ms.ToArray()
            $ms.Dispose()
            if ($bytes.Length) { return $bytes }
        }
    }

    # Older sources, and anything that only offers a device-independent bitmap.
    $img = [Windows.Forms.Clipboard]::GetImage()
    if ($img) {
        $ms = New-Object IO.MemoryStream
        $img.Save($ms, [Drawing.Imaging.ImageFormat]::Png)
        $bytes = $ms.ToArray()
        $ms.Dispose()
        $img.Dispose()
        return $bytes
    }

    # A file copied in Explorer is a third shape -- no image on the clipboard, a
    # path list instead. Same gesture for the user, so it is worth the few lines.
    $files = [Windows.Forms.Clipboard]::GetFileDropList()
    if ($files.Count -eq 1 -and $files[0] -match '\.(png|jpe?g|bmp|gif)$') {
        if ($files[0] -match '\.png$') { return [IO.File]::ReadAllBytes($files[0]) }
        # The receiver only accepts PNG, so re-encode rather than teach it every
        # format System.Drawing happens to open.
        $img = [Drawing.Image]::FromFile($files[0])
        $ms = New-Object IO.MemoryStream
        $img.Save($ms, [Drawing.Imaging.ImageFormat]::Png)
        $bytes = $ms.ToArray()
        $ms.Dispose()
        $img.Dispose()
        return $bytes
    }

    return $null
}

function Write-ClipImageResult {
    param([hashtable]$Fields)
    # The hotkey reads this instead of scraping stdout: AHK's RunWait only hands
    # back an integer, and an integer cannot say which pane took the image.
    $path = Join-Path $env:LOCALAPPDATA 'herdr-clip.last'
    $lines = foreach ($k in 'status', 'target', 'pane', 'agent', 'title', 'path', 'saved', 'candidates') {
        if ($Fields.ContainsKey($k)) { "$k=$($Fields[$k])" }
    }
    try { Set-Content -LiteralPath $path -Value $lines -Encoding utf8 } catch { }
}

function Send-ClipImage {
    [CmdletBinding()]
    param(
        # Omit to read it off the running ssh.exe processes.
        [string]$Target,
        # Explicit pane on the far side; otherwise the receiver uses the focused one.
        [string]$Pane,
        # Send a file already on disk instead of the clipboard. Used by the hotkey
        # when it has to ask which host first -- the image is saved before the
        # menu appears, so the second pass must not re-read a clipboard that may
        # have changed in the meantime.
        [string]$FromSaved,
        # Overridable so this can be exercised before the receiving host has
        # rebuilt: `-RecvCommand 'bash ~/.nix/home-manager/programs/herdr/herdr-clip-recv'`.
        [string]$RecvCommand = 'herdr-clip-recv'
    )

    if ($FromSaved) {
        if (-not (Test-Path -LiteralPath $FromSaved)) {
            Write-ClipImageLog "saved file is gone: $FromSaved"
            Write-ClipImageResult @{ status = 'noimage' }
            return
        }
        $bytes = [IO.File]::ReadAllBytes($FromSaved)
        $saved = $FromSaved
    } else {
        $bytes = Get-ClipImageBytes
        if (-not $bytes) {
            Write-ClipImageLog 'clipboard holds no image'
            Write-ClipImageResult @{ status = 'noimage' }
            Write-Warning 'clipboard holds no image'
            return
        }
        $saved = Save-ClipImageLocally $bytes
    }

    if (-not $Target) {
        # @() around the call, not just inside the function: PowerShell unrolls a
        # returned array, so a single match comes back as a bare string. A string
        # still answers .Count = 1, so every guard here passed and $found[0] took
        # its first CHARACTER -- "macmini" became "m" and ssh failed with
        # "Could not resolve hostname m". Printing the value with -join hid it;
        # only the type was ever wrong.
        $found = @(Resolve-HerdrTarget)
        if ($found.Count -eq 0) {
            # No fallback host. A default is precisely how an image ends up typed
            # into a session on a machine the user is not looking at.
            Write-ClipImageLog "no ssh session open; image kept at $saved"
            Write-ClipImageResult @{ status = 'notarget'; saved = $saved }
            return
        }
        if ($found.Count -gt 1) {
            Write-ClipImageLog "several ssh sessions: $($found -join ', ')"
            Write-ClipImageResult @{ status = 'multi'; saved = $saved; candidates = ($found -join ',') }
            return
        }
        # Select-Object rather than [0], for the same reason: on a bare string
        # (which is what an unrolled single-element return looks like) indexing
        # yields a character while Select-Object yields the whole string. Two
        # defenses because only one of them is visible at the call site.
        $Target = $found | Select-Object -First 1
    }

    # The target is concatenated into a command line further up the stack, so it
    # is validated rather than trusted, even though it came from a local process.
    if ($Target -notmatch '^[A-Za-z0-9._@-]+$') {
        Write-ClipImageLog "refusing odd target: $Target"
        Write-ClipImageResult @{ status = 'sshfail'; target = $Target; saved = $saved }
        return
    }

    # `$base64 | ssh ...` is the obvious way to write this and it hangs forever:
    # PowerShell writes the string but never closes the native command's stdin, so
    # `base64 -d` on the far side waits on an EOF that never comes (measured -- it
    # left a blocked reader on macmini and a stuck ssh here). Redirecting from a
    # file gives a real EOF; the same round trip then takes ~500 ms.
    $stdin = [IO.Path]::GetTempFileName()
    $stdout = [IO.Path]::GetTempFileName()
    $stderr = [IO.Path]::GetTempFileName()

    # ASCII, and written with .NET rather than Out-File, so no BOM and no console
    # codepage can get into a string that is by definition plain ASCII.
    [IO.File]::WriteAllText($stdin, [Convert]::ToBase64String($bytes), [Text.Encoding]::ASCII)

    # ConnectTimeout is not optional here: the hotkey blocks on RunWait, and a
    # sleeping host measured 75 s before ssh gave up on its own.
    # Start-Process drops quote characters inside an argument, so the remote
    # command must survive being word-split -- which it does, because ssh joins
    # its arguments with spaces and the remote shell re-parses them.
    $sshArgs = @('-o', 'BatchMode=yes', '-o', 'ConnectTimeout=5', $Target, $RecvCommand)
    if ($Pane) { $sshArgs += @('--pane', $Pane) }

    try {
        $proc = Start-Process ssh -ArgumentList $sshArgs `
            -RedirectStandardInput $stdin -RedirectStandardOutput $stdout -RedirectStandardError $stderr `
            -NoNewWindow -Wait -PassThru
        $code = $proc.ExitCode
        $output = @(Get-Content -LiteralPath $stdout)
        $errors = (Get-Content -LiteralPath $stderr -Raw)
    } finally {
        # The temp file holds the screenshot; do not leave it in %TEMP%.
        Remove-Item -LiteralPath $stdin, $stdout, $stderr -Force -ErrorAction SilentlyContinue
    }

    # The path is the receiver's LAST line by contract, and the match is
    # case-insensitive, so take the last hit rather than the first -- a pane
    # titled "export .PNG" would otherwise win.
    $remote = $output | Where-Object { $_ -match '\.png$' } | Select-Object -Last 1
    $ident = $output | Where-Object { $_ -match '^herdr-clip-recv: pane=' } | Select-Object -Last 1

    $pane = ''; $agent = ''; $title = ''
    if ($ident -match '^herdr-clip-recv: pane=(\S+) agent=(\S+) title=(.*)$') {
        $pane = $Matches[1]; $agent = $Matches[2]; $title = $Matches[3]
    }

    if ($code -ne 0) {
        Write-ClipImageLog "ssh $Target exited ${code}: $errors"
        Write-ClipImageResult @{ status = 'recvfail'; target = $Target; saved = $saved; path = $remote }
        Write-Error "herdr-clip: $Target refused the image (exit $code); see $env:LOCALAPPDATA\herdr-clip.log"
        return
    }

    if (-not $remote) {
        Write-ClipImageLog "no path came back from ${Target}: $($output -join ' | ')"
        Write-ClipImageResult @{ status = 'recvfail'; target = $Target; saved = $saved }
        Write-Error "herdr-clip: $Target returned no path"
        return
    }

    # ${agent} braced on purpose: a bare `$agent:` parses as a scope qualifier
    # (like $env:) and is a syntax error, not a variable followed by a colon.
    Write-ClipImageLog "sent $($bytes.Length) bytes to ${Target} pane=$pane agent=${agent}: $remote"
    Write-ClipImageResult @{
        status = 'ok'; target = $Target; pane = $pane; agent = $agent
        title  = $title; path = $remote; saved = $saved
    }
    return $remote
}

function Invoke-HerdrClipHotkey {
    # Entry point for herdr-clip.ahk. Exists so the hotkey has one thing to call
    # and a stable set of exit codes; the detail always goes to herdr-clip.last.
    [CmdletBinding()]
    param([string]$Target, [string]$Pane, [string]$FromSaved)

    $null = Send-ClipImage -Target $Target -Pane $Pane -FromSaved $FromSaved
    $status = 'recvfail'
    try {
        $last = Get-Content -LiteralPath (Join-Path $env:LOCALAPPDATA 'herdr-clip.last') -ErrorAction Stop
        $line = $last | Where-Object { $_ -like 'status=*' } | Select-Object -First 1
        if ($line) { $status = $line.Substring(7) }
    } catch { }

    exit $(switch ($status) {
        'ok' { 0 }
        'noimage' { 1 }
        'notarget' { 2 }
        'multi' { 3 }
        default { 4 }
    })
}
