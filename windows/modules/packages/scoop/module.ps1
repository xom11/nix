@{
    Description = 'Scoop: all portable CLI dev tools (scoop v0.5.3+ supports admin install)'
    Apply = {
        param($Ctx)
        Install-ScoopPackages -Buckets @('extras') -Packages @(
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
            'kanata'
        )
    }
}
