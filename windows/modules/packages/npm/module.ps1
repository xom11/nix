@{
    Description = 'Global npm packages (AI CLIs)'
    Apply = {
        param($Ctx)
        Install-NpmPackages @(
            '@anthropic-ai/claude-code'
            '@google/gemini-cli'
            '@github/copilot'
        )
    }
}
