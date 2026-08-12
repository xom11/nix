@{
    Description = 'Packages: winget + scoop, both declared in pkg.toml and applied by dotpkg'
    Apply       = {
        param($Ctx)

        # scoop first. dotpkg MANAGES scoop, it does not install it -- its own
        # README says so: "on a machine with neither, it has nothing to do".
        # On a machine that already has scoop this returns immediately.
        if (-not (Install-Scoop)) { return }

        if (-not (Get-Command dotpkg -ErrorAction SilentlyContinue)) {
            # Deliberately not downloaded here. This repo pins no dotpkg version
            # anywhere -- not flake.lock, not a scoop manifest -- so fetching one
            # would invent a second pin channel that nothing declares and nothing
            # tests. Whoever sets up a machine takes the binary by hand.
            throw 'dotpkg not found in PATH. Take the binary from https://github.com/xom11/dotpkg/releases, check it against the release SHA256SUMS, and put it somewhere on PATH.'
        }

        # Explicit paths. dotpkg defaults to ./pkg.toml and apply.ps1 guarantees
        # no working directory; a run whose CWD happened to be system32 reported
        # "cannot read pkg.toml" and nothing else.
        #
        # These are the LINKS in the home directory, not the repo files, on
        # purpose: a human running `dotpkg status` from their home directory then
        # reads exactly what this module reads. dotfiles.dotpkg creates them and
        # apply.ps1 runs it first -- windows/tests/apply.Tests.ps1 pins that order.
        $config = Join-Path $env:USERPROFILE 'pkg.toml'
        $lock   = Join-Path $env:USERPROFILE 'pkg.lock'
        foreach ($p in @($config, $lock)) {
            if (-not (Test-Path -LiteralPath $p)) {
                throw "$p is missing -- the dotfiles.dotpkg link module has to run before this one"
            }
        }

        # --clone-missing-buckets: a fresh machine has no xom11 bucket on disk,
        #   and the lock pins commits inside buckets that have to be there.
        # --keep-going: matches how apply.ps1 already behaves -- one broken
        #   package should not hold the other thirty-nine. Removals stay held
        #   regardless of this flag.
        # --yes: apply.ps1 is not an interactive session; the prompt would hang a
        #   scheduled or SSH run forever.
        # No --allow-prune, deliberately: apply.ps1 has never uninstalled
        #   anything. Keeping that also keeps this clear of dotpkg's refusal to
        #   remove a user-scope winget package from an elevated process, and
        #   apply.ps1 always self-elevates.
        #
        # KNOWN LIMITATION, measured on a14 2026-08-12. Over SSH this reads scoop
        # state through each app's `current` junction, and Redirection Guard --
        # inherited from the sshd service -- refuses to traverse junctions created
        # by a non-elevated user. Those packages come back as "installed, but its
        # state could not be read" and are SKIPPED, not reinstalled. So an
        # apply.ps1 run over SSH quietly leaves some packages untouched. Nothing
        # breaks; it just does less than it says. Run it from a real user session
        # when that matters. The old Install-ScoopPackages did not have this
        # problem because it never read a manifest through `current`.
        dotpkg apply --yes --keep-going --clone-missing-buckets --config $config --lock $lock
        $rc = $LASTEXITCODE
        $global:LASTEXITCODE = 0

        # throw, not Write-Fail: apply.ps1 counts a module as failed only when it
        # throws. Write-Fail prints in red and still lands in the ok column.
        if ($rc -eq 0) {
            Write-OK 'dotpkg apply'
        } elseif ($rc -eq 2) {
            throw 'dotpkg apply: a declared package has no pkg.lock entry. Run `dotpkg update` and commit the lock.'
        } else {
            throw "dotpkg apply exited with $rc"
        }
    }
}
