@{
    Description = 'Packages: winget + scoop, both declared in pkg.toml and applied by dotpkg'
    Apply       = {
        param($Ctx)

        # Why each decision here is what it is: CLAUDE.md, section "dotpkg".
        $MinDotpkg = [version]'0.2.0'   # pkg.toml uses [winget.opts]; 0.1.0 rejects the whole file

        # apply.ps1 sets $ErrorActionPreference = 'Stop' and this scriptblock runs
        # under the caller's. Stop turns native stderr into a terminating error,
        # and dotpkg writes warnings there -- so every native call goes through here.
        function Invoke-Native {
            param([string]$Exe, [string[]]$Arguments, [switch]$Capture)
            $prev = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try {
                if ($Capture) { $out = (& $Exe @Arguments 2>&1 | Out-String) }
                else          { & $Exe @Arguments 2>&1 | ForEach-Object { Write-Host $_ } }
            } finally { $ErrorActionPreference = $prev }
            $rc = $LASTEXITCODE
            $global:LASTEXITCODE = 0
            [pscustomobject]@{ ExitCode = $rc; Output = $out }
        }

        # dotpkg manages scoop but does not install it.
        if (-not (Install-Scoop)) { return }

        # dotpkg itself comes from scoop and is declared in pkg.toml, so pkg.lock
        # pins it by bucket commit. The bucket must exist before an install can
        # name it, and dotpkg's --clone-missing-buckets cannot help: it is the
        # thing not yet installed.
        if (-not (Get-Command dotpkg -ErrorAction SilentlyContinue)) {
            if ((Invoke-Native scoop @('bucket', 'list') -Capture).Output -notmatch 'xom11') {
                Invoke-Native scoop @('bucket', 'add', 'xom11', 'https://github.com/xom11/scoop-bucket') | Out-Null
            }
            Invoke-Native scoop @('install', 'xom11/dotpkg') | Out-Null
            Update-Path
            if (-not (Get-Command dotpkg -ErrorAction SilentlyContinue)) {
                throw 'scoop install xom11/dotpkg ran but dotpkg is still not on PATH'
            }
        }

        # Also catches an older copy earlier in PATH shadowing the scoop shim.
        $verRaw = (Invoke-Native dotpkg @('--version') -Capture).Output
        if ($verRaw -notmatch '(\d+\.\d+\.\d+)') {
            throw "cannot read a version out of ``dotpkg --version`` (got: $($verRaw.Trim()))"
        }
        if ([version]$Matches[1] -lt $MinDotpkg) {
            throw "dotpkg $($Matches[1]) is too old; pkg.toml needs $MinDotpkg. Run ``scoop update dotpkg`` -- if the version does not move, something earlier in PATH is shadowing the shim (``Get-Command dotpkg -All``)."
        }

        # Repo files, never symlinks: dotpkg rewrites the lock through fs::rename,
        # which replaces a symlink with a regular file. Explicit paths also cover
        # apply.ps1 guaranteeing no working directory.
        $dotpkgDir = Join-Path $Ctx.RepoRoot 'home-manager\dotfiles\windows\dotpkg'
        $config = Join-Path $dotpkgDir 'pkg.toml'
        $lock   = Join-Path $dotpkgDir 'pkg.lock'
        foreach ($p in @($config, $lock)) {
            if (-not (Test-Path -LiteralPath $p)) {
                throw "$p is missing -- it is committed to this repo, so a working tree without it is broken"
            }
        }

        # --keep-going: one broken package must not hold the rest, as elsewhere in
        #   apply.ps1. --yes: no interactive session. No prune flag: apply.ps1 has
        #   never uninstalled anything.
        # Over SSH this silently skips scoop packages whose `current` junction
        # Redirection Guard refuses to traverse -- run it from a user session.
        $rc = (Invoke-Native dotpkg @(
            'apply', '--yes', '--keep-going', '--clone-missing-buckets'
            '--config', $config, '--lock', $lock
        )).ExitCode

        # 0 done · 3 only a running app left · 1 needs a person · 2+ refused, nothing changed.
        # apply.ps1 counts a module failed only when it throws.
        switch ($rc) {
            0 { Write-OK 'dotpkg apply' }
            3 { Write-OK 'dotpkg apply (a package was skipped because it was running)' }
            1 { throw 'dotpkg apply: something failed, could not be prepared, or was held. Read the plan above -- the "app was running" case is exit 3.' }
            default { throw "dotpkg apply refused the run (exit $rc) and changed nothing. Usually a declared package with no pkg.lock entry -- run ``dotpkg update`` and commit the lock." }
        }
    }
}
