@{
    Description = 'Scoop: only packages not available in winget (kanata, stylua, yamlfmt). Auto de-elevated via gsudo when admin.'
    Apply = {
        param($Ctx)
        Install-ScoopPackages -Packages @(
            'kanata'        # keyboard remapper CLI
            'stylua'        # Lua formatter
            'yamlfmt'       # YAML formatter
        )
    }
}
