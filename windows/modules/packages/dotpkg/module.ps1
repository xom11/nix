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

        # Straight at the repo files, not at links in the home directory.
        #
        # There WERE links -- %USERPROFILE%\pkg.toml and pkg.lock -- and they were
        # removed on 2026-08-12 after a measurement: dotpkg writes the lock
        # atomically (File::create on a temp file, then fs::rename over the
        # target), and a rename REPLACES a symlink with a regular file. Measured
        # on a14: LinkType went from SymbolicLink to blank on the first
        # `dotpkg update`, the new pin landed in the home-directory copy, and the
        # repo silently stopped receiving updates. Nothing about that is visible
        # unless you go looking at LinkType.
        #
        # So nothing writable sits behind a symlink here. To drive dotpkg by hand,
        # cd into the directory below and run it with no flags at all -- its own
        # defaults (./pkg.toml, ./pkg.lock) then resolve to these same files.
        #
        # Passing them explicitly also covers apply.ps1 guaranteeing no working
        # directory: a run whose CWD happened to be system32 reported "cannot read
        # pkg.toml" and nothing else.
        $dotpkgDir = Join-Path $Ctx.RepoRoot 'home-manager\dotfiles\windows\dotpkg'
        $config = Join-Path $dotpkgDir 'pkg.toml'
        $lock   = Join-Path $dotpkgDir 'pkg.lock'
        foreach ($p in @($config, $lock)) {
            if (-not (Test-Path -LiteralPath $p)) {
                throw "$p is missing -- it is committed to this repo, so a working tree without it is broken"
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
        #
        # The two failing codes were measured on a14 2026-08-12, with one package
        # declared and an empty lock, because the README's account is true only
        # for the flags it assumes:
        #     without --keep-going : exit 2, "nothing has been changed"
        #     with    --keep-going : exit 1, the ready packages still applied
        # This module passes --keep-going, so 1 is the code a missing pin actually
        # produces here and 2 is the one that never fires. Both are handled: the
        # flag could come off one day, and a wrong exit-code message is worse than
        # none because it sends the reader after the wrong file.
        if ($rc -eq 0) {
            Write-OK 'dotpkg apply'
        } elseif ($rc -eq 1) {
            throw 'dotpkg apply: some packages could not be prepared or verified (the rest were still applied, because --keep-going). The usual cause is a declared package with no pkg.lock entry -- run `dotpkg update` and commit the lock. Read the output above for which.'
        } elseif ($rc -eq 2) {
            throw 'dotpkg apply: something could not be prepared, so nothing was changed. Usually a declared package with no pkg.lock entry -- run `dotpkg update` and commit the lock.'
        } else {
            throw "dotpkg apply exited with $rc"
        }
    }
}
