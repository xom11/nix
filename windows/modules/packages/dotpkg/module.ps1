@{
    Description = 'Packages: winget + scoop, both declared in pkg.toml and applied by dotpkg'
    Apply       = {
        param($Ctx)

        # scoop first. dotpkg MANAGES scoop, it does not install it -- its own
        # README says so: "on a machine with neither, it has nothing to do".
        # On a machine that already has scoop this returns immediately.
        if (-not (Install-Scoop)) { return }

        # dotpkg comes from scoop and declares ITSELF in pkg.toml, so its version
        # is pinned by a bucket commit in pkg.lock like every other package.
        #
        # This block used to throw and send you to the GitHub release, on the
        # stated grounds that installing it here "would invent a second pin
        # channel that nothing declares and nothing tests". That was true while
        # no manifest existed. xom11/scoop-bucket carries one now, so the bucket
        # IS the channel, pkg.lock is where it is pinned, and
        # dotpkgDeclaration.Tests.ps1 is what gates it -- bootstrapping stopped
        # inventing anything the day the manifest landed.
        if (-not (Get-Command dotpkg -ErrorAction SilentlyContinue)) {
            $prevEap = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try {
                # The bucket has to be there before an install can name it, and
                # dotpkg's own --clone-missing-buckets cannot help: it is the
                # thing not yet installed.
                if ((scoop bucket list | Out-String) -notmatch 'xom11') {
                    Write-Info 'scoop bucket add xom11'
                    scoop bucket add xom11 https://github.com/xom11/scoop-bucket
                }
                Write-Info 'scoop install xom11/dotpkg'
                scoop install xom11/dotpkg
            } finally {
                $ErrorActionPreference = $prevEap
                $global:LASTEXITCODE = 0
            }

            # PATH in this process predates the shim scoop just wrote.
            Update-Path
            if (-not (Get-Command dotpkg -ErrorAction SilentlyContinue)) {
                throw 'scoop install xom11/dotpkg ran but dotpkg is still not on PATH'
            }
        }

        # Version gate. pkg.toml uses `[winget.opts] pin = "none"`, which 0.1.0
        # does not merely ignore -- it refuses the whole file with
        # `unknown field 'opts', expected 'packages' or 'guard'`, so every
        # package goes unmanaged and the module fails with a message that points
        # at the config rather than at the binary. Measured on a14 2026-08-12.
        #
        # This gate is only possible because 0.2.0 bumped the version: builds
        # from main used to report 0.1.0 too, so nothing could tell them apart.
        #
        # It still earns its place now that scoop installs dotpkg, and for a
        # second reason: an older copy EARLIER IN PATH silently wins over the
        # scoop shim. Measured on a14 2026-08-13 -- `%USERPROFILE%\.local\bin`
        # precedes `scoop\shims`, and a hand-installed dotpkg.exe there shadowed
        # scoop's for as long as it existed. That is the same trap `stylua` is
        # still caught in on that machine. Without this gate the symptom would be
        # `dotpkg update` faithfully upgrading a binary nobody runs.
        #
        # Do not raise the floor without a matching reason: pkg.lock pins dotpkg
        # by bucket commit, so a floor above what the lock resolves to fails
        # every machine at once.
        $MinDotpkg = [version]'0.2.0'
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $verRaw = (& dotpkg --version 2>&1 | Out-String)
        } finally {
            $ErrorActionPreference = $prevEap
            $global:LASTEXITCODE = 0
        }
        if ($verRaw -notmatch '(\d+\.\d+\.\d+)') {
            throw "cannot read a version out of ``dotpkg --version`` (got: $($verRaw.Trim()))"
        }
        $haveDotpkg = [version]$Matches[1]
        if ($haveDotpkg -lt $MinDotpkg) {
            throw "dotpkg $haveDotpkg is too old; pkg.toml needs $MinDotpkg or newer for [winget.opts] pin = ""none"". Run ``scoop update dotpkg`` -- and if that reports the version you already have, something earlier in PATH is shadowing the scoop shim (check ``Get-Command dotpkg -All``)."
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
        # $ErrorActionPreference has to come off for the call itself, and this is
        # not defensive tidying -- without it the module cannot work at all.
        #
        # apply.ps1 sets $ErrorActionPreference = 'Stop'. This Apply block is a
        # scriptblock invoked with `&`, so it runs under the CALLER's preference,
        # not the file's. Under 'Stop', PowerShell 5.1 turns any output a native
        # command writes to stderr into a terminating NativeCommandError -- and
        # dotpkg writes its warnings there. Measured on a14 2026-08-12: the module
        # threw on the first warning line, one about `winget list` collapsing
        # duplicate rows, which is not an error at all and cannot be made to go
        # away. Every real apply.ps1 run would have failed this module before the
        # exit code was ever read.
        #
        # Scoped with try/finally so the caller gets its own setting back even if
        # the call throws for a real reason.
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            dotpkg apply --yes --keep-going --clone-missing-buckets --config $config --lock $lock
            $rc = $LASTEXITCODE
        } finally {
            $ErrorActionPreference = $prevEap
        }
        $global:LASTEXITCODE = 0

        # 1 warns, 2 and up throw. That split is not squeamishness -- it follows
        # dotpkg's own definition, which is written in terms of what the operator
        # must do next rather than what went wrong:
        #
        #   0  the plan is fully realised, nothing outstanding
        #   1  something is OUTSTANDING -- a package failed, was held, could not
        #      be prepared, "or was skipped because its own process was running.
        #      That last one is not a failure"
        #   2  refused before anything was attempted; nothing changed
        #
        # So 1 deliberately mixes a real failure with a package that was merely
        # busy, and the exit code cannot tell them apart. On this fleet the busy
        # case is the NORMAL one: python, beckon and kanata are managed by scoop
        # and are almost always running. Measured on a14 2026-08-12 with a fully
        # resolved lock and nothing wrong: `7 of 7 changes ready, 0 failed,
        # 1 skipped` -> exit 1, and that 1 was python.
        #
        # Throwing on 1 would therefore paint apply.ps1 red on nearly every run,
        # which is the fastest way to teach someone to stop reading red. The
        # warning still names what is outstanding, and dotpkg has already printed
        # the per-package detail above it.
        #
        # throw, where it is used, matters: apply.ps1 counts a module as failed
        # only when it throws. Write-Fail prints in red and still lands in the ok
        # column.
        if ($rc -eq 0) {
            Write-OK 'dotpkg apply'
        } elseif ($rc -eq 3) {
            # 3 was added upstream in response to this integration: "everything
            # dotpkg could do succeeded, and the only thing left is a package
            # skipped because its own process was running". Nothing to diagnose,
            # so it is a success with a note rather than a warning. On this fleet
            # it is the ordinary steady state: python, beckon and kanata come
            # from scoop and are running essentially all the time.
            Write-OK 'dotpkg apply (a package was skipped because it was running)'
        } elseif ($rc -eq 1) {
            # Throws, since 0.2.0. Before exit 3 existed, 1 also carried the
            # benign running-skip and throwing here would have painted apply.ps1
            # red on every run -- so it only warned, and a real failure warned
            # too. 3 took the benign case away, so 1 now means what it says:
            # something failed, could not be prepared, or was held. That needs a
            # person, and a warning is too weak for it.
            #
            # The version gate above is what makes this safe: a 0.1.0 binary
            # cannot reach here, because it cannot read pkg.toml at all.
            throw 'dotpkg apply: something failed, could not be prepared, or was held. Read the plan above -- this is not the "app was running" case, which is exit 3.'
        } else {
            # 2 is "refused before anything was attempted, nothing changed": a
            # guard fired, or a declared package has no pkg.lock entry. Both need
            # a person, and neither is fixed by running apply again.
            throw "dotpkg apply refused the run (exit $rc) and changed nothing. Usually a declared package with no pkg.lock entry -- run ``dotpkg update`` and commit the lock."
        }
    }
}
