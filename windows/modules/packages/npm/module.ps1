@{
    Description = 'Global npm packages (none managed here right now)'
    Apply = {
        param($Ctx)

        # Deliberately empty, so this module is a no-op. What is installed globally on
        # a14 as of 2026-08-07 -- @github/copilot, @google/gemini-cli, 9router, claude,
        # sql.js -- is none of it managed from here. Two of those are the names below,
        # so read the list as "not managed", not "not present". Uncommenting one hands
        # apply.ps1 ownership of a package something else already updates: the
        # two-updaters problem programs.herdr and dotfiles.ai.pi both exist to avoid.
        #
        # The early return matters: `npm ls -g` measured 2077-2332 ms warm on a14 (far
        # worse cold), and it used to run before the list was even looked at.
        $Packages = @(
            # '@anthropic-ai/claude-code'
            # '@google/gemini-cli'
            # '@github/copilot'
        )
        if (-not $Packages) { return }

        if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
            Write-Warn 'npm not installed - skipping (nodejs comes from scoop)'
            return
        }
        $installed = @(npm ls -g --depth=0 --parseable 2>$null)
        foreach ($pkg in $Packages) {
            if ($installed -match [regex]::Escape($pkg)) {
                Write-Skip "npm:$pkg"
            } else {
                Write-Info "npm i -g $pkg"
                npm install -g $pkg
            }
        }
    }
}
