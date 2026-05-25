@{
    Description = 'Scoop CLI tools (zip-based, all work via patched 7-Zip dep)'
    Apply = {
        param($Ctx)
        Install-ScoopPackages -Packages @(
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
