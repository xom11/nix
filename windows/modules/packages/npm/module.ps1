@{
    Description = 'Global npm packages (none managed here right now)'
    Apply = {
        param($Ctx)

        # The list is deliberately empty, and Install-NpmPackages returns immediately on an
        # empty one -- it used to run `npm ls -g` first regardless, which measured 2077-2332 ms
        # warm on a14 (far worse cold) to compare a global package list against nothing.
        #
        # What is actually installed globally on a14, as of 2026-08-07, none of it by this
        # module: @github/copilot, @google/gemini-cli, 9router, claude, sql.js. Two of those are
        # the very names commented out below, so do not read the commented list as "not present
        # on the machine" -- it only means "not managed from here". Uncommenting one hands
        # apply.ps1 ownership of a package something else is already updating, which is the
        # two-updaters problem programs.herdr and dotfiles.ai.pi both exist to avoid.
        Install-NpmPackages @(
            # '@anthropic-ai/claude-code'
            # '@google/gemini-cli'
            # '@github/copilot'
        )
    }
}
