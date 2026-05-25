@{
    Description = 'Scoop + non-winget packages (kanata, stylua, yamlfmt, im-select); auto de-elevated via gsudo when admin'
    Apply = {
        param($Ctx)
        Install-ScoopPackages -Buckets @('extras') -Packages @(
            'kanata'        # keyboard remapper CLI
            'stylua'        # Lua formatter
            'yamlfmt'       # YAML formatter
            'im-select'     # input method switcher (extras bucket)
        )
    }
}
