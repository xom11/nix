# Config only -- the herdr binary is NOT installed by apply.ps1, for the same reason
# dotfiles.ai.pi is config-only: herdr ships `herdr update` and `herdr channel` and keeps itself
# current from its own release feed. A second installer writing the same path would be two
# updaters racing, and whichever ran last would win.
#
# That is the opposite of the nix hosts, where home-manager/programs/herdr owns the binary via
# pkgs.herdr and therefore gives `herdr update` up -- a read-only store path cannot be replaced.
# Windows has no such constraint, so the self-updater is kept.
#
# One-time install on a machine that has never had it. Windows is PREVIEW-ONLY: the installer
# errors out on `-Channel stable`, and herdr's own default channel is already preview there.
#   $env:HERDR_CHANNEL='preview'; irm https://herdr.dev/install.ps1 | iex
# It lands in %LOCALAPPDATA%\Programs\Herdr\bin and puts that directory first on the user PATH
# via HKCU\Environment. No admin needed.
#
# `herdr --remote macmini` does NOT work from here, and no version bump fixes that: upstream
# states plainly that "Native Windows `herdr --remote` is not part of the beta", alongside
# direct terminal attach, live handoff and remote clipboard image bridging. The documented
# shape from Windows is `ssh macmini` and then `herdr` on that side, where it behaves like
# tmux on the remote shell. Protocol numbers (0.8.0 is 19) therefore never come into it on
# this platform -- they only matter between two ends that can actually attach.
#
# The one thing that shape loses is pasting a screenshot into an agent, since the local
# clipboard never reaches the server. Tab+v fills that hole by hand: ahk\ferry.ahk ->
# pwsh\ps1.d\ferry.ps1, which ssh's the image across and types the path back here. It
# needs nothing installed on the far end and nothing to do with herdr -- it works the
# same into tmux or a plain shell -- which is why it is not named after herdr.
#
# Upstream publishes no ARM64 Windows build: install.ps1 maps Arm64 to windows-x86_64 and says
# so out loud ("installing the x86_64 build under Windows emulation"). On a14 herdr therefore
# runs under Prism -- verified by PE header (machine 0x8664), deliberate, and the same accepted
# trade-off as kanata and rustup. The bundled ConPTY does ship an arm64 OpenConsole.exe, so the
# pty layer itself is native.
@{
    Description = 'herdr: config.toml generated from the shared file plus a Windows-only default_shell'
    Apply = {
        param($Ctx)

        $srcDir = Join-Path $Ctx.HomeManagerDir 'programs\herdr\herdr.d'
        $src    = Join-Path $srcDir 'config.toml'
        $dstDir = Join-Path $env:APPDATA 'herdr'
        $dst    = Join-Path $dstDir 'config.toml'

        if (-not (Test-Path -LiteralPath $src)) {
            Write-Warn "herdr -> shared config missing: $src"
            return
        }

        # Why this module generates a file instead of linking one, like every other entry here.
        #
        # herdr reads exactly ONE config file -- no include directive, no per-platform tables.
        # The shared file cannot carry `default_shell` because the correct value differs per OS,
        # and leaving it empty is not neutral on Windows: herdr then spawns Windows PowerShell
        # 5.1, which reads Documents\WindowsPowerShell, while dotfiles.pwsh links this repo's
        # profile into Documents\PowerShell (the pwsh 7 path). The pane comes up with no
        # profile, no aliases, no functions, no agenix drop-in -- it looks broken while every
        # log line says success.
        #
        # Upstream documents an empty value as "$SHELL, then /bin/sh". The Windows build
        # ignores $SHELL -- measured on a14: setting it changed nothing, setting default_shell
        # did. So the config value is the only lever there is.
        #
        # The trade-off, stated plainly: the target is a copy, not a symlink, so editing the
        # shared config does not reach Windows until apply.ps1 runs again (then
        # `herdr server reload-config`). That is the price of keeping ONE source of truth; the
        # alternative -- a second config.toml checked in for Windows -- drifts silently the
        # first time a keybinding changes on a mac.
        $pwshExe = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
        if (-not $pwshExe) {
            Write-Warn 'herdr -> pwsh not on PATH; skipping (packages.pwsh installs it)'
            return
        }
        # Resolved at apply time rather than hardcoded, so this survives pwsh moving and stays
        # correct on a host that installed it somewhere else.
        if ($pwshExe.Contains("'")) {
            Write-Warn "herdr -> pwsh path contains a quote, cannot express as a TOML literal: $pwshExe"
            return
        }

        # Inject INTO the existing [terminal] table. Appending a second [terminal] at the end
        # looks harmless and is not: TOML forbids redefining a table, so herdr rejects the whole
        # file and silently falls back to its defaults -- which is exactly the bug being fixed.
        # A duplicate `default_shell` key inside one table is equally fatal, so an existing line
        # is replaced rather than added to.
        $lines    = Get-Content -LiteralPath $src
        $out      = [System.Collections.Generic.List[string]]::new()
        $inTerm   = $false
        $injected = $false
        $shellLine = "default_shell = '$pwshExe'"

        foreach ($line in $lines) {
            $trimmed = $line.Trim()

            # Leaving [terminal] for another table without having injected yet: do it now, so
            # the key lands inside the table it belongs to.
            if ($inTerm -and $trimmed.StartsWith('[') -and $trimmed -ne '[terminal]') {
                if (-not $injected) { $out.Add($shellLine); $injected = $true }
                $inTerm = $false
            }

            if ($trimmed -eq '[terminal]') {
                $out.Add($line)
                $out.Add($shellLine)
                $inTerm   = $true
                $injected = $true
                continue
            }

            # Drop any uncommented default_shell the shared file may grow later; ours wins on
            # Windows and two of them would be invalid TOML.
            if ($inTerm -and $trimmed -match '^default_shell\s*=') { continue }

            $out.Add($line)
        }
        if ($inTerm -and -not $injected) { $out.Add($shellLine) }

        if (-not $injected) {
            Write-Warn "herdr -> no [terminal] table in $src; not generating"
            return
        }

        $header = @(
            '# GENERATED by windows/modules/programs/herdr -- do not edit this copy.'
            '# Source: home-manager/programs/herdr/herdr.d/config.toml'
            '# The only Windows delta is default_shell; see the module for why.'
            ''
        )
        $generated = (($header + $out) -join "`r`n") + "`r`n"

        if (-not (Test-Path -LiteralPath $dstDir)) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }

        # An earlier revision of this repo linked config.toml straight to the shared file. That
        # link must go BEFORE anything writes here: Set-Content follows a symlink and writes the
        # TARGET, which would push this Windows-only default_shell into the file every other
        # host reads.
        if (Test-Path -LiteralPath $dst) {
            $item = Get-Item -LiteralPath $dst -Force
            if ($item.LinkType -in 'SymbolicLink', 'Junction') {
                Remove-Item -LiteralPath $dst -Force
                Write-Info 'herdr -> replaced the old symlink with a generated file'
            }
        }

        $current = if (Test-Path -LiteralPath $dst) {
            Get-Content -LiteralPath $dst -Raw -ErrorAction SilentlyContinue
        } else { $null }

        if ($current -eq $generated) {
            Write-Skip "$dst"
        } else {
            Set-Content -LiteralPath $dst -Value $generated -NoNewline -Encoding utf8
            Write-OK "$dst  (default_shell = $pwshExe)"
            Write-Info 'herdr -> run `herdr server reload-config` to apply without restarting'
        }

        # This one has no platform delta, so it stays a real link and keeps the live-edit
        # property. Individual file, never the whole %APPDATA%\herdr directory -- the running
        # server keeps herdr.sock, session.json and herdr*.log in there.
        $detection = Join-Path $srcDir 'agent-detection\claude.toml'
        if (Test-Path -LiteralPath $detection) {
            New-IdempotentSymlink -Source $detection `
                -Target (Join-Path $dstDir 'agent-detection\claude.toml') | Out-Null
        }
    }
}
