@{
    Description = 'Scoop CLI dev tools (auto de-elevated via gsudo when admin)'
    Apply = {
        param($Ctx)
        Install-ScoopPackages -Packages @(
            # ---- Original scoop list ----
            'git'
            'nodejs'
            'gh'
            'bat'
            'ripgrep'
            'fzf'
            'fastfetch'
            'neovim'
            'lazygit'
            'lazydocker'
            'yazi'
            'aichat'
            'shfmt'
            'yamlfmt'
            'stylua'

            # ---- Not in winget ----
            'kanata'
        )
    }
}
