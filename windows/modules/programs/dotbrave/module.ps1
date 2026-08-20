@{
    Description = 'Apply brave.toml: shortcuts, settings, force-installed PWAs'
    Apply = {
        param($Ctx)

        # The same file the nix hosts read -- no copy, no Windows variant.
        $toml = Join-Path $Ctx.HomeManagerDir 'dotfiles\browser\dotbrave\brave.toml'
        if (-not (Test-Path -LiteralPath $toml)) {
            throw "brave.toml not found at $toml"
        }

        if (-not (Get-Command uvx -ErrorAction SilentlyContinue)) {
            Write-Skip 'dotbrave -> uvx khong co (scoop install uv)'
            return
        }

        # PyPI rather than git: it publishes prebuilt wheels, so uvx downloads and
        # unpacks instead of resolving and building from source on every run --
        # measured faster on a14 for both first and subsequent runs.
        #
        # Pinned deliberately, the role flake.lock plays on the nix hosts: without a
        # pin, every upstream release would run straight into a script holding
        # Administrator rights and writing HKLM policy, unreviewed. Bump by hand.
        $src = 'dotbrave==0.3.3'

        # No `--skip pwa` here, unlike the nix side, because apply.ps1 already runs
        # as Administrator and may write HKLM.
        #
        # Allowed is not the same as applied. --unattended never closes Brave, so
        # which tables land depends on Brave's state: closed gets all three; open
        # with a DevTools endpoint gets all three; open WITHOUT an endpoint -- the
        # normal state here -- gets only [pwa], and the CLI says so on stderr while
        # still exiting 0.
        #
        # So the Write-OK below means "the command did not fail", not "all three
        # applied". Close Brave and rerun for all three.
        Write-Info "dotbrave -> apply $toml"

        # 'Continue' for this block: uv writes progress to stderr even for a
        # prebuilt wheel, and under apply.ps1's script-scoped 'Stop' every stderr
        # line from a native command becomes a terminating exception in PowerShell
        # 5.1 -- taking out the $LASTEXITCODE read below even on success.
        $ErrorActionPreference = 'Continue'
        & uvx --from $src dotbrave apply --unattended $toml

        # Process-global: read then reset, or it leaks into the next module.
        $rc = $LASTEXITCODE
        $global:LASTEXITCODE = 0

        if ($rc -ne 0) {
            throw "dotbrave apply exited $rc"
        }
        Write-OK 'dotbrave -> apply ran (stderr names any table left unapplied)'
    }
}
