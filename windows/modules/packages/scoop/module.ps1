@{
    Description = 'Scoop: all portable CLI dev tools (scoop v0.5.3+ supports admin install)'
    Apply = {
        param($Ctx)
        Install-ScoopPackages -Buckets @(
            'extras'
            'xom11=https://github.com/xom11/scoop-bucket'
        ) -Packages @(
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
            'zellij'
            'aichat'
            'shfmt'
            'yamlfmt'
            'stylua'
            'actionlint'
            'kanata'
            'xom11/beckon'
            'python'
            'go'
            'rustup'
            'uv'
            'age'
        ) -KeepArchitecture @(
            # launch-kanata.ahk and its watchdog run one exact filename,
            # kanata_windows_tty_winIOv2_x64.exe, which the arm64 build does not carry. An
            # architecture swap here takes the keyboard down on the machine you would need
            # the keyboard to fix, and the watchdog launches quiet so nothing says why.
            'kanata'

            # The scoop package is only rustup-init.exe; the toolchain lives in ~/.rustup and
            # rustup picks its own host triple (already aarch64 on a14). Swapping the
            # bootstrapper gains nothing, and its post_install stays resident long enough to
            # lock the file the next install has to write -- which is exactly how a14 lost
            # rustup for half an hour.
            'rustup'

            # Installed 32-bit, with native wheels compiled against it. Changing the
            # interpreter's architecture breaks every one of them, and that is a decision to
            # make deliberately rather than during a package sweep.
            'python'
        )
    }
}
