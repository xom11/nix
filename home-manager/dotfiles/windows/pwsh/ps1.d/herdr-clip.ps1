# Send-ClipImage -- push the Windows clipboard image into a Herdr session on
# another machine, so an agent running there can read it.
#
# The gap this fills: `herdr --remote` already bridges a local clipboard image
# into the remote session, but upstream does not ship --remote on Windows
# ("Native Windows `herdr --remote` is not part of the beta") and has not wired
# its clipboard-image reader there either. What works from Windows is `ssh
# macmini` and then `herdr` on that side -- which leaves a screenshot taken here
# with no route in. This carries it across: clipboard -> PNG -> base64 -> ssh
# stdin -> herdr-clip-recv, which saves the file and types the path into the
# focused pane. Nothing is installed on the far end beyond that one script
# (home-manager/programs/herdr/herdr-clip-recv).
#
# This MUST run in the interactive desktop session, which is why the hotkey in
# herdr-clip.ahk exists rather than a shell function you call over ssh. Measured
# on a14: a process started by sshd reports SessionId 0 while explorer.exe sits
# in SessionId 1, and the two window stations own separate clipboards -- writing
# a marker string from the ssh session and reading it back returns that session's
# own clipboard, never the desktop's. An ssh-side copy of this can therefore only
# ever see an empty clipboard.

function Write-ClipImageLog {
    param([string]$Message)
    # Same shape as ahk-main.log: a hotkey that fails silently needs somewhere to
    # have said why, since nothing here has a console attached.
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    try { Add-Content -LiteralPath (Join-Path $env:LOCALAPPDATA 'herdr-clip.log') -Value $line } catch { }
}

function Send-ClipImage {
    [CmdletBinding()]
    param(
        [string]$Target = 'macmini',
        # Explicit pane instead of whatever the far side has focused.
        [string]$Pane,
        # Overridable so this can be exercised before the receiving host has
        # rebuilt: `-RecvCommand 'bash ~/.nix/home-manager/programs/herdr/herdr-clip-recv'`.
        [string]$RecvCommand = 'herdr-clip-recv'
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $bytes = $null

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
        }
    }

    # Older sources, and anything that only offers a device-independent bitmap.
    if (-not $bytes) {
        $img = [Windows.Forms.Clipboard]::GetImage()
        if ($img) {
            $ms = New-Object IO.MemoryStream
            $img.Save($ms, [Drawing.Imaging.ImageFormat]::Png)
            $bytes = $ms.ToArray()
            $ms.Dispose()
            $img.Dispose()
        }
    }

    # A file copied in Explorer is a third shape -- no image on the clipboard, a
    # path list instead. Same gesture for the user, so it is worth the six lines.
    if (-not $bytes) {
        $files = [Windows.Forms.Clipboard]::GetFileDropList()
        if ($files.Count -eq 1 -and $files[0] -match '\.(png|jpe?g|bmp|gif)$') {
            if ($files[0] -match '\.png$') {
                $bytes = [IO.File]::ReadAllBytes($files[0])
            } else {
                # The receiver only accepts PNG, so re-encode rather than teach it
                # every format System.Drawing happens to open.
                $img = [Drawing.Image]::FromFile($files[0])
                $ms = New-Object IO.MemoryStream
                $img.Save($ms, [Drawing.Imaging.ImageFormat]::Png)
                $bytes = $ms.ToArray()
                $ms.Dispose()
                $img.Dispose()
            }
        }
    }

    if (-not $bytes) {
        Write-ClipImageLog 'clipboard holds no image'
        Write-Warning 'clipboard holds no image'
        return
    }

    # `$base64 | ssh ...` is the obvious way to write this and it hangs forever:
    # PowerShell writes the string but never closes the native command's stdin, so
    # `base64 -d` on the far side waits on an EOF that never comes (measured -- it
    # left a blocked reader on macmini and a stuck ssh here). Redirecting from a
    # file gives a real EOF; the same round trip then takes ~500 ms.
    $stdin  = [IO.Path]::GetTempFileName()
    $stdout = [IO.Path]::GetTempFileName()
    $stderr = [IO.Path]::GetTempFileName()

    # ASCII, and written with .NET rather than Out-File, so no BOM and no console
    # codepage can get into a string that is by definition plain ASCII.
    [IO.File]::WriteAllText($stdin, [Convert]::ToBase64String($bytes), [Text.Encoding]::ASCII)

    # Start-Process drops quote characters inside an argument, so the remote
    # command must survive being word-split -- which it does, because ssh joins
    # its arguments with spaces and the remote shell re-parses them. It does mean
    # a path with a space in it would not survive; none of these have one.
    $sshArgs = @('-o', 'BatchMode=yes', $Target, $RecvCommand)
    if ($Pane) { $sshArgs += @('--pane', $Pane) }

    try {
        $proc = Start-Process ssh -ArgumentList $sshArgs `
            -RedirectStandardInput $stdin -RedirectStandardOutput $stdout -RedirectStandardError $stderr `
            -NoNewWindow -Wait -PassThru
        $code   = $proc.ExitCode
        $output = Get-Content -LiteralPath $stdout
        $errors = (Get-Content -LiteralPath $stderr -Raw)
    } finally {
        # The temp file holds the screenshot; do not leave it in %TEMP%.
        Remove-Item -LiteralPath $stdin, $stdout, $stderr -Force -ErrorAction SilentlyContinue
    }

    if ($code -ne 0) {
        Write-ClipImageLog "ssh $Target exited ${code}: $errors"
        Write-Error "herdr-clip: ssh $Target failed (exit $code); see $env:LOCALAPPDATA\herdr-clip.log"
        return
    }

    # Match the path rather than trusting the last line: an ssh config with a
    # `Match exec` block prints its own noise on this platform, and that noise
    # would otherwise become the return value.
    $remote = $output | Where-Object { $_ -match '\.png$' } | Select-Object -Last 1
    if (-not $remote) {
        Write-ClipImageLog "no path came back from ${Target}: $output"
        Write-Error "herdr-clip: $Target returned no path"
        return
    }

    Write-ClipImageLog "sent $($bytes.Length) bytes to ${Target}: $remote"
    return $remote
}
