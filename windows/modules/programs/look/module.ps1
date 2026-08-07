@{
    Description = 'Look launcher: latest GitHub release, per-user NSIS install under %LOCALAPPDATA%'
    Apply = {
        param($Ctx)

        # The GitHub release is the only Windows channel there is. Upstream
        # publishes an AUR package, a .deb, an AppImage, a Homebrew tap and this
        # NSIS installer -- there is no winget manifest (no manifests/k/kunkka19xx
        # in microsoft/winget-pkgs) and no scoop bucket, so Install-WingetPackages
        # and Install-ScoopPackages have nothing to point at.
        $Repo = 'kunkka19xx/look'

        # Tracks latest rather than pinning, by request. The SHA256 check below
        # still proves the download matches what upstream published -- but that
        # is transport integrity, not review: a new release reaches this elevated
        # script the moment it ships. The installer itself is currentUser mode
        # and needs no admin, so if that ever matters, de-elevating this one call
        # through gsudo would cost the privilege without costing the update.
        $installDir = Join-Path $env:LOCALAPPDATA 'Programs\Look'
        $exe        = Join-Path $installDir 'lookapp.exe'

        # Upstream publishes x86_64 only ("native ARM builds aren't published",
        # README). On a14 that means the launcher runs under Prism emulation --
        # deliberate, not drift, so it is a warning rather than a skip.
        #
        # Get-NativeArchitecture rather than the PROCESSOR_ARCHITECTURE variable, which describes
        # the process: an apply run from an emulated x64 shell would answer AMD64 and drop the
        # warning below on a machine that is emulating. Only the message differs here -- both
        # branches install the same x64 build -- but the warning is the only thing that says
        # this binary is not native, so losing it silently is the whole cost.
        $native = Get-NativeArchitecture
        switch ($native) {
            'ARM64' { Write-Warn 'look -> x64 build only; runs under Prism emulation on ARM64' }
            'AMD64' { }
            default {
                Write-Warn "look -> no release for '$native' - skipping"
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

        try {
            $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" `
                -Headers @{ 'User-Agent' = 'nix-windows-apply' } -TimeoutSec 30
        } catch {
            # Offline or rate-limited. An existing install is still fine; a
            # missing one is not. Either way this must not fail the whole apply.
            if ($installed) {
                Write-Skip "look -> $installed (release check failed)"
            } else {
                Write-Warn "look -> cannot reach the release feed and it is not installed: $_"
            }
            return
        }

        $version = $release.tag_name -replace '^v', ''
        if ($version -notmatch '^\d+(\.\d+){1,3}$') {
            Write-Warn "look -> unexpected tag '$($release.tag_name)' - skipping"
            return
        }
        $latest = [version]$version

        if ($installed -and $installed -ge $latest) {
            Write-Skip "look -> $installed is current"
            return
        }

        # Take the URLs off the release itself instead of rebuilding them from a
        # naming convention: tauri-cli's NSIS name is
        # `<ProductName>_<version>_x64-setup.exe` today, and a guessed URL that
        # stops matching turns into a 404 at download time rather than a clear
        # "this release has no Windows asset".
        $setup = $release.assets | Where-Object { $_.name -like 'Look_*_x64-setup.exe' } | Select-Object -First 1
        $sums  = $release.assets | Where-Object { $_.name -like '*windows-checksums.txt' } | Select-Object -First 1
        if (-not $setup) {
            Write-Warn "look -> release $version has no x64 setup asset - skipping"
            return
        }

        $tmp = Join-Path $env:TEMP "look-$version"
        New-Item -ItemType Directory -Path $tmp -Force | Out-Null
        try {
            $setupPath = Join-Path $tmp $setup.name
            Write-Info "look -> downloading $($setup.name)"
            Invoke-WebRequest -Uri $setup.browser_download_url -OutFile $setupPath -UseBasicParsing

            # Never install an unverified binary. A release that ships no
            # checksums file is a stop, not a shrug: this runs elevated.
            if (-not $sums) { throw "release $version publishes no windows-checksums.txt" }

            $sumsPath = Join-Path $tmp $sums.name
            Invoke-WebRequest -Uri $sums.browser_download_url -OutFile $sumsPath -UseBasicParsing

            # Lines read '<sha256>  <filename>'. Anchor on the filename at end of
            # line so a multi-asset checksums file cannot match the wrong row --
            # and escape it, because the version dots are regex wildcards.
            $escaped = [regex]::Escape($setup.name)
            $line = Get-Content -LiteralPath $sumsPath |
                Where-Object { $_ -match "\s$escaped\s*$" } |
                Select-Object -First 1
            if (-not $line) { throw "checksums file has no entry for $($setup.name)" }

            $expected = ($line -split '\s+')[0].ToLower()
            $actual   = (Get-FileHash -LiteralPath $setupPath -Algorithm SHA256).Hash.ToLower()
            if ($actual -ne $expected) {
                throw "SHA256 mismatch for $($setup.name): expected=$expected actual=$actual"
            }
            Write-OK 'look -> SHA256 verified'

            # NSIS cannot overwrite a locked binary. Only reached when an install
            # is actually about to happen -- the Write-Skip above already
            # returned for an up-to-date build, so a running instance at the
            # current version is never killed out from under the user.
            Get-Process -Name 'lookapp' -ErrorAction SilentlyContinue |
                Stop-Process -Force -ErrorAction SilentlyContinue

            # /S = silent. /D= must be the LAST argument and must NOT be quoted,
            # even when the path contains spaces -- NSIS convention, not a typo.
            Write-Info ("look -> {0} {1}" -f $(if ($installed) { "upgrading from $installed to" } else { 'installing' }), $latest)
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
            Write-OK "look -> $latest installed to $installDir"
        } finally {
            Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
