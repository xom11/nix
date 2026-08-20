# Send-FerryImage -- copy the Windows clipboard image to whichever machine this
# box is currently ssh'd into, and hand back the path it landed on. ferry.ahk
# types that path into the focused window here.
#
# Exists because `herdr --remote` covers this on macOS and Linux but not on
# Windows, leaving a screenshot taken here with no route into an `ssh` session.
#
# MUST run in the interactive desktop session, hence the AHK hotkey rather than
# a function called over ssh: sshd runs in SessionId 0, explorer.exe in
# SessionId 1, and the two window stations own separate clipboards.
#
# The target cannot come from a constant or from the far end -- a Herdr server
# keeps no record of where a client came from, and SSH_CLIENT in a pane is a
# fossil. It is read from the argv of the running ssh.exe at keypress time.
# Parser validated against 27 real `ps` cases, including:
#   ssh -f -p 22 macmini ssh -o ... rog sleep 60   -> macmini, NOT rog
#   ssh -F <path> -S <path> -T macmini exec ...    -> both flags eat a path
#   ssh: /Users/kln/.ssh/control-... [mux]         -> a title, not an argv

# Options that consume the following token. Get this list wrong and a config
# path becomes a hostname.
$script:FerrySshTakesArg = 'BbcDEeFIiJLlmOopQRSWw'

function Write-FerryLog {
    param([string]$Message)
    # A hotkey that fails silently needs somewhere to have said why; nothing here
    # has a console attached.
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    try { Add-Content -LiteralPath (Join-Path $env:LOCALAPPDATA 'ferry.log') -Value $line } catch { }
}

function Split-CommandLine {
    param([string]$Line)
    # Quoted runs stay whole, everything else breaks on whitespace. Only the exe
    # path is normally quoted.
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
    # ControlMaster processes carry a title instead of an argv. Cannot occur on
    # Windows; kept so both platforms share one tested parser.
    if ($CommandLine.StartsWith('ssh: ') -or $CommandLine.TrimEnd().EndsWith('[mux]')) { return $null }
    if ($CommandLine -match 'remote-client-bridge' -or $CommandLine -match '[/\\]herdr-ssh-') { return $null }

    $argv = Split-CommandLine $CommandLine
    if ($argv.Count -lt 2) { return $null }

    # Split on both separators by hand: [IO.Path]::GetFileName only knows the
    # separator of the host it runs on, so under pwsh on macOS it reads the whole
    # Windows path as one file name.
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
            # Bundled flags (-Nfp 2222) and inline values (-p2222): only the LAST
            # character can swallow the next token, and only if nothing follows it.
            $body = $tok.Substring(1)
            $inlineValue = $false
            for ($k = 0; $k -lt $body.Length; $k++) {
                if ($script:FerrySshTakesArg.Contains($body[$k])) {
                    if ($k -lt $body.Length - 1) { $inlineValue = $true }
                    break
                }
            }
            if (-not $inlineValue -and $script:FerrySshTakesArg.Contains($body[$body.Length - 1])) {
                $i += 2
            } else {
                $i += 1
            }
            continue
        }
        # First non-option token is the destination; the rest is a remote command.
        return $tok
    }
    return $null
}

function Resolve-FerryTarget {
    [CmdletBinding()]
    param()
    # Filter on Name to keep ssh-agent, scp and sftp out, and on SessionId because
    # anything sshd spawns lands in Session 0 and would become a candidate for a
    # hotkey pressed on the desktop.
    $session = (Get-Process -Id $PID).SessionId
    $procs = @(Get-CimInstance Win32_Process -Filter "Name='ssh.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.SessionId -eq $session })
    $targets = foreach ($p in $procs) {
        $t = Get-SshTargetFromCommandLine $p.CommandLine
        if ($t) { $t }
    }
    # user@host and host are one destination; dedupe on the host part but return
    # a form ssh accepts.
    $seen = @{}
    $unique = foreach ($t in $targets) {
        $alias = $t.Split('@')[-1]
        if (-not $seen.ContainsKey($alias)) { $seen[$alias] = $true; $t }
    }
    return @($unique)
}

function Save-FerryImageLocally {
    param([byte[]]$Bytes)
    # Written before anything can fail, so a sleeping host never costs the
    # screenshot. Scratch, not an archive -- %TEMP% rather than Pictures. It only
    # outlives the send for the several-hosts menu, which re-reads it seconds later.
    $dir = Join-Path $env:TEMP 'ferry'
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $path = Join-Path $dir ('{0}.png' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    [IO.File]::WriteAllBytes($path, $Bytes)
    Get-ChildItem -LiteralPath $dir -Filter '*.png' -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-1) } |
        Remove-Item -Force -ErrorAction SilentlyContinue
    return $path
}

function Get-FerryImageBytes {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Snipping Tool, Chrome and Firefox publish a real PNG. Taking those bytes
    # verbatim keeps the alpha channel; GetImage() round-trips through a DIB and
    # flattens transparency to black.
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

    # Older sources, and anything offering only a device-independent bitmap.
    $img = [Windows.Forms.Clipboard]::GetImage()
    if ($img) {
        $ms = New-Object IO.MemoryStream
        $img.Save($ms, [Drawing.Imaging.ImageFormat]::Png)
        $bytes = $ms.ToArray()
        $ms.Dispose()
        $img.Dispose()
        return $bytes
    }

    # A file copied in Explorer is a third shape: no image, a path list instead.
    $files = [Windows.Forms.Clipboard]::GetFileDropList()
    if ($files.Count -eq 1 -and $files[0] -match '\.(png|jpe?g|bmp|gif)$') {
        if ($files[0] -match '\.png$') { return [IO.File]::ReadAllBytes($files[0]) }
        # The receiver only accepts PNG.
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

function Write-FerryResult {
    param([hashtable]$Fields)
    # The hotkey reads this instead of stdout: AHK's RunWait hands back only an
    # integer, which cannot carry the path to be typed.
    $path = Join-Path $env:LOCALAPPDATA 'ferry.last'
    $lines = foreach ($k in 'status', 'target', 'path', 'saved', 'candidates') {
        if ($Fields.ContainsKey($k)) { "$k=$($Fields[$k])" }
    }
    try { Set-Content -LiteralPath $path -Value $lines -Encoding utf8 } catch { }
}

function Send-FerryImage {
    [CmdletBinding()]
    param(
        # Omit to read it off the running ssh.exe processes.
        [string]$Target,
        # Send a file already on disk. The hotkey uses this on its second pass so
        # the several-hosts menu cannot re-read a clipboard that has moved on.
        [string]$FromSaved
    )

    if ($FromSaved) {
        if (-not (Test-Path -LiteralPath $FromSaved)) {
            Write-FerryLog "saved file is gone: $FromSaved"
            Write-FerryResult @{ status = 'noimage' }
            return
        }
        $bytes = [IO.File]::ReadAllBytes($FromSaved)
        $saved = $FromSaved
    } else {
        $bytes = Get-FerryImageBytes
        if (-not $bytes) {
            Write-FerryLog 'clipboard holds no image'
            Write-FerryResult @{ status = 'noimage' }
            Write-Warning 'clipboard holds no image'
            return
        }
        $saved = Save-FerryImageLocally $bytes
    }

    if (-not $Target) {
        # @() at the call site, not just inside: PowerShell unrolls a returned
        # array, so one match comes back as a bare string -- which still answers
        # .Count = 1, so [0] took its first CHARACTER and "macmini" became "m".
        $found = @(Resolve-FerryTarget)
        if ($found.Count -eq 0) {
            # No fallback host on purpose: a default is how an image gets typed
            # into a machine the user is not looking at.
            Write-FerryLog "no ssh session open; image kept at $saved"
            Write-FerryResult @{ status = 'notarget'; saved = $saved }
            return
        }
        if ($found.Count -gt 1) {
            Write-FerryLog "several ssh sessions: $($found -join ', ')"
            Write-FerryResult @{ status = 'multi'; saved = $saved; candidates = ($found -join ',') }
            return
        }
        # Select-Object rather than [0], same reason as above.
        $Target = $found | Select-Object -First 1
    }

    # Concatenated into a command line further up, so validate rather than trust.
    if ($Target -notmatch '^[A-Za-z0-9._@-]+$') {
        Write-FerryLog "refusing odd target: $Target"
        Write-FerryResult @{ status = 'sshfail'; target = $Target; saved = $saved }
        return
    }

    # THIS is the receiver -- nothing is installed on the far side, so any box
    # reachable by ssh works without a rebuild. The `sh -c` wrapper insures
    # against a login shell that does not speak ${VAR:-default}, such as fish.
    $remoteScript =
        'd=${XDG_CACHE_HOME:-$HOME/.cache}/ferry; mkdir -p "$d"; ' +
        'f=$d/$(date +%Y%m%d-%H%M%S)-$$.png; base64 -d > "$f" || exit 1; ' +
        'find "$d" -name "*.png" -type f -mtime +1 -delete 2>/dev/null; ' +
        'wc -c < "$f"; echo "$f"'

    # [Diagnostics.Process] rather than Start-Process, for two reasons:
    #  - Start-Process DROPS quotes inside an argument, and the remote script is
    #    one quoted argument.
    #  - stdin here can be closed. `$base64 | ssh ...` hangs forever because
    #    PowerShell never closes a native command's stdin, so `base64 -d` waits on
    #    an EOF that never comes. Closing the stream IS the EOF, and no temp file.
    # ConnectTimeout is not optional: the hotkey blocks on RunWait, and a sleeping
    # host measured 75 s before ssh gave up on its own.
    $psi = [Diagnostics.ProcessStartInfo]::new('ssh')
    foreach ($a in @('-o', 'BatchMode=yes', '-o', 'ConnectTimeout=5', $Target, "sh -c '$remoteScript'")) {
        $psi.ArgumentList.Add($a)
    }
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    # Base64 is ASCII; pinning it keeps a console codepage from adding a BOM.
    $psi.StandardInputEncoding = [Text.Encoding]::ASCII

    $code = 1
    $output = @()
    $errors = ''
    try {
        $proc = [Diagnostics.Process]::Start($psi)
        # Safe to write it all before reading: the remote answers with two short
        # lines, so its output cannot fill the pipe mid-write.
        $proc.StandardInput.Write([Convert]::ToBase64String($bytes))
        $proc.StandardInput.Close()
        $output = @($proc.StandardOutput.ReadToEnd() -split "`r?`n" | Where-Object { $_ -ne '' })
        $errors = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit()
        $code = $proc.ExitCode
    } catch {
        Write-FerryLog "ssh $Target could not start: $($_.Exception.Message)"
        Write-FerryResult @{ status = 'sshfail'; target = $Target; saved = $saved }
        return
    }

    # LAST .png line, not the first: an ssh config with a `Match exec` block
    # prints its own noise on Windows.
    $remote = $output | Where-Object { $_ -match '\.png$' } | Select-Object -Last 1

    if ($code -ne 0) {
        Write-FerryLog "ssh $Target exited ${code}: $errors"
        Write-FerryResult @{ status = 'recvfail'; target = $Target; saved = $saved; path = $remote }
        Write-Error "ferry: $Target refused the image (exit $code); see $env:LOCALAPPDATA\ferry.log"
        return
    }

    # Comparing the size the far side reports beats a PNG-signature check: a
    # truncated transfer keeps a valid signature.
    $reported = $output | Where-Object { $_ -match '^\s*\d+\s*$' } | Select-Object -Last 1
    if ($reported -and ([int]$reported.Trim() -ne $bytes.Length)) {
        Write-FerryLog "size mismatch on ${Target}: sent $($bytes.Length), landed $reported"
        Write-FerryResult @{ status = 'recvfail'; target = $Target; saved = $saved; path = $remote }
        Write-Error "ferry: $Target received $reported of $($bytes.Length) bytes"
        return
    }

    if (-not $remote) {
        Write-FerryLog "no path came back from ${Target}: $($output -join ' | ')"
        Write-FerryResult @{ status = 'recvfail'; target = $Target; saved = $saved }
        Write-Error "ferry: $Target returned no path"
        return
    }

    # ${Target} braced: a bare `$Target:` parses as a scope qualifier.
    Write-FerryLog "sent $($bytes.Length) bytes to ${Target}: $remote"
    Write-FerryResult @{ status = 'ok'; target = $Target; path = $remote; saved = $saved }
    return $remote
}

function Invoke-FerryHotkey {
    # Entry point for ferry.ahk: one thing to call, a stable set of exit codes.
    # Detail always goes to ferry.last.
    [CmdletBinding()]
    param([string]$Target, [string]$FromSaved)

    $null = Send-FerryImage -Target $Target -FromSaved $FromSaved
    $status = 'recvfail'
    try {
        $last = Get-Content -LiteralPath (Join-Path $env:LOCALAPPDATA 'ferry.last') -ErrorAction Stop
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
