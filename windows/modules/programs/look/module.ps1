@{
    Description = 'Look launcher: pinned NSIS release, per-user install under %LOCALAPPDATA%'
    Apply = {
        param($Ctx)

        # Pinned, not "latest". This downloads an .exe from GitHub and runs it,
        # and apply.ps1 runs elevated -- so an unpinned source would hand every
        # future upstream release a run as Administrator, unreviewed and with no
        # record of which build was installed. Same reasoning as the
        # `dotbrave==0.3.3` pin next door; this is what flake.lock does for the
        # Nix hosts. Bump by hand from the release list:
        #   https://github.com/kunkka19xx/look/releases
        $Version = '0.6.9'
        $Repo    = 'kunkka19xx/look'

        # Tauri's NSIS bundle sets installMode = currentUser, so this lands in
        # the user profile and needs no admin. apply.ps1 being elevated does not
        # redirect it: SSH here logs in as a local admin *user*, so
        # %LOCALAPPDATA% is still that user's -- the same reason the scoop
        # comment in apply.ps1 gives for scoop's per-user layout.
        $installDir = Join-Path $env:LOCALAPPDATA 'Programs\Look'
        $exe        = Join-Path $installDir 'lookapp.exe'

        # Upstream publishes x86_64 only ("native ARM builds aren't published",
        # README). On a14 that means the launcher runs under Prism emulation --
        # deliberate, not drift, so it is a warning rather than a skip. If an
        # arm64 asset ever appears, $setupName below is the only line to change.
        switch ($env:PROCESSOR_ARCHITECTURE) {
            'ARM64' { Write-Warn 'look -> x64 build only; runs under Prism emulation on ARM64' }
            'AMD64' { }
            default {
                Write-Warn "look -> no release for '$env:PROCESSOR_ARCHITECTURE' - skipping"
                return
            }
        }

        # Tauri writes ProductVersion as '0.6.9' or '0.6.9.0' depending on the
        # toolchain, so take the leading numeric run and compare as [version];
        # a string compare would call '0.6.10' older than '0.6.9'.
        $installed = $null
        if (Test-Path -LiteralPath $exe) {
            $raw = (Get-Item -LiteralPath $exe).VersionInfo.ProductVersion
            if ($raw -match '^\d+(\.\d+){1,3}') { $installed = [version]$Matches[0] }
        }

        # -ge, not -eq: the pin is a floor, not an exact match. A newer build
        # installed by hand is not upstream code that just auto-ran through
        # here, so there is nothing to protect against by downgrading it.
        if ($installed -and $installed -ge [version]$Version) {
            Write-Skip "look -> $installed already installed"
            return
        }

        $setupName = "Look_${Version}_x64-setup.exe"
        $base      = "https://github.com/$Repo/releases/download/v$Version"

        $tmp = Join-Path $env:TEMP "look-$Version"
        New-Item -ItemType Directory -Path $tmp -Force | Out-Null
        try {
            $setupPath = Join-Path $tmp $setupName
            $sumsPath  = Join-Path $tmp 'checksums.txt'

            Write-Info "look -> downloading $setupName"
            Invoke-WebRequest -Uri "$base/$setupName" -OutFile $setupPath -UseBasicParsing
            Invoke-WebRequest -Uri "$base/Look-$Version-windows-checksums.txt" -OutFile $sumsPath -UseBasicParsing

            # Lines read '<sha256>  <filename>'. Anchor on the filename at end of
            # line so a future multi-asset checksums file cannot match the wrong
            # row -- and escape it, because the version dots are regex wildcards.
            $escaped = [regex]::Escape($setupName)
            $line = Get-Content -LiteralPath $sumsPath |
                Where-Object { $_ -match "\s$escaped\s*$" } |
                Select-Object -First 1
            if (-not $line) { throw "checksums file has no entry for $setupName" }

            $expected = ($line -split '\s+')[0].ToLower()
            $actual   = (Get-FileHash -LiteralPath $setupPath -Algorithm SHA256).Hash.ToLower()
            if ($actual -ne $expected) {
                throw "SHA256 mismatch for ${setupName}: expected=$expected actual=$actual"
            }
            Write-OK 'look -> SHA256 verified'

            # NSIS cannot overwrite a locked binary. Only reached when an install
            # is actually about to happen -- the Write-Skip above already
            # returned for an up-to-date build, so a running instance at the
            # pinned version is never killed out from under the user.
            Get-Process -Name 'lookapp' -ErrorAction SilentlyContinue |
                Stop-Process -Force -ErrorAction SilentlyContinue

            # /S = silent. /D= must be the LAST argument and must NOT be quoted,
            # even when the path contains spaces -- NSIS convention, not a typo.
            Write-Info ("look -> {0} {1}" -f $(if ($installed) { "upgrading from $installed to" } else { 'installing' }), $Version)
            $proc = Start-Process -FilePath $setupPath -ArgumentList @('/S', "/D=$installDir") -Wait -PassThru
            if ($proc.ExitCode -ne 0) { throw "installer exited with $($proc.ExitCode)" }
            if (-not (Test-Path -LiteralPath $exe)) {
                throw "installer reported success but $exe is missing"
            }

            # Deliberately does not launch. Over SSH apply.ps1 runs in session 0,
            # which has no desktop to draw on -- a GUI started there is an
            # invisible process holding the Alt+Space hotkey. The app registers
            # its own autostart on first run (sync_autostart in src/main.rs), so
            # opening it once at the machine is all that is left to do.
            Write-OK "look -> $Version installed to $installDir (open it once at the machine to arm autostart)"
        } finally {
            Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
