@{
    Description = 'Look launcher: latest GitHub release, per-user NSIS install under %LOCALAPPDATA%'
    Apply = {
        param($Ctx)

        # The GitHub release is the only Windows channel: no winget manifest and
        # no scoop bucket, so neither dotpkg backend can express this.
        $Repo = 'kunkka19xx/look'

        # Tracks latest rather than pinning, by request. The SHA256 check proves
        # transport integrity, not review -- a new release reaches this elevated
        # script the moment it ships. The installer is currentUser mode and needs
        # no admin, so gsudo could de-elevate this call if that ever matters.
        $installDir = Join-Path $env:LOCALAPPDATA 'Programs\Look'
        $exe        = Join-Path $installDir 'lookapp.exe'

        # x86_64 only upstream, so on a14 this runs under Prism -- deliberate, hence
        # a warning rather than a skip. Get-NativeArchitecture, not
        # PROCESSOR_ARCHITECTURE, which describes the PROCESS: an apply run from an
        # emulated x64 shell would answer AMD64 and silently drop that warning.
        $native = Get-NativeArchitecture
        switch ($native) {
            'ARM64' { Write-Warn 'look -> x64 build only; runs under Prism emulation on ARM64' }
            'AMD64' { }
            default {
                Write-Warn "look -> no release for '$native' - skipping"
                return
            }
        }

        # Tauri writes '0.6.9' or '0.6.9.0' depending on toolchain, so compare as
        # [version] -- a string compare calls '0.6.10' older than '0.6.9'.
        $installed = $null
        if (Test-Path -LiteralPath $exe) {
            $raw = (Get-Item -LiteralPath $exe).VersionInfo.ProductVersion
            if ($raw -match '^\d+(\.\d+){1,3}') { $installed = [version]$Matches[0] }
        }

        try {
            $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" `
                -Headers @{ 'User-Agent' = 'nix-windows-apply' } -TimeoutSec 30
        } catch {
            # Offline or rate-limited: must not fail the whole apply.
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

        # URLs from the release itself, not rebuilt from a naming convention: a
        # guessed URL that stops matching 404s at download time instead of saying
        # the release has no Windows asset.
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

            # This runs elevated, so a missing checksums file is a stop.
            if (-not $sums) { throw "release $version publishes no windows-checksums.txt" }

            $sumsPath = Join-Path $tmp $sums.name
            Invoke-WebRequest -Uri $sums.browser_download_url -OutFile $sumsPath -UseBasicParsing

            # Anchor on the filename at end of line so a multi-asset checksums
            # file cannot match the wrong row; escaped because dots are wildcards.
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
            # is really happening, so a current running instance is never killed.
            Get-Process -Name 'lookapp' -ErrorAction SilentlyContinue |
                Stop-Process -Force -ErrorAction SilentlyContinue

            # /D= must be LAST and must NOT be quoted, even with spaces in the
            # path -- NSIS convention, not a typo.
            Write-Info ("look -> {0} {1}" -f $(if ($installed) { "upgrading from $installed to" } else { 'installing' }), $latest)
            $proc = Start-Process -FilePath $setupPath -ArgumentList @('/S', "/D=$installDir") -Wait -PassThru
            if ($proc.ExitCode -ne 0) { throw "installer exited with $($proc.ExitCode)" }
            if (-not (Test-Path -LiteralPath $exe)) {
                throw "installer reported success but $exe is missing"
            }

            # Deliberately does not launch: over SSH this runs in session 0, with
            # no desktop, so a GUI started there is an invisible process holding
            # the Alt+Space hotkey. The app registers its own autostart on first
            # run, so opening it once at the machine is all that remains.
            Write-OK "look -> $latest installed to $installDir"
        } finally {
            Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
