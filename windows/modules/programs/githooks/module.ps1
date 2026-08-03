@{
    Description = 'Point git at .githooks so the pre-push secret guard runs on this machine'
    Apply       = {
        param($Ctx)

        # Windows counterpart of the home.activation block in
        # home-manager/programs/git/default.nix. Same reasoning, same value: a
        # machine that has been applied has the fence up, with nothing to remember
        # after a fresh clone.

        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            Write-Warn 'git not found in PATH'
            return
        }

        $hookDir = Join-Path $Ctx.RepoRoot '.githooks'
        $hook = Join-Path $hookDir 'pre-push'
        if (-not (Test-Path -LiteralPath $hook)) {
            Write-Fail "missing $hook"
            return
        }

        # Forward slashes: a backslash starts an escape sequence inside a git config
        # value, so a Windows path round-trips wrong often enough to be a real trap.
        # Git on Windows accepts either form when reading.
        $value = ($hookDir -replace '\\', '/')

        $current = (git -C $Ctx.RepoRoot config --local --get core.hooksPath 2>$null)
        $global:LASTEXITCODE = 0 # `--get` exits 1 when unset; that is not an error here

        if ($current -eq $value) {
            Write-Skip "core.hooksPath -> already $value"
            return
        }

        git -C $Ctx.RepoRoot config core.hooksPath $value 2>&1 | Out-Null
        $rc = $LASTEXITCODE
        $global:LASTEXITCODE = 0

        # Read it back rather than trust the exit code. The failure this module
        # exists to prevent is a fence that looks installed and is not.
        $now = (git -C $Ctx.RepoRoot config --local --get core.hooksPath 2>$null)
        $global:LASTEXITCODE = 0

        if ($rc -eq 0 -and $now -eq $value) { Write-OK "core.hooksPath -> $value" }
        else { Write-Fail "core.hooksPath -> set failed (exit $rc, now '$now')" }
    }
}
