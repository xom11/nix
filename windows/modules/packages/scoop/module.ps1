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

            # nvim's treesitter config asks for 31 parsers and calls install() on every start
            # for whatever is missing. Building one needs the tree-sitter CLI, which the nix
            # hosts get from home.packages in home-manager/programs/nvim -- and Windows never
            # runs home-manager, it only symlinks lua/. Without this, every single launch
            # downloaded 31 tarballs and printed 31 build failures.
            # The C compiler comes from the Visual Studio Build Tools already on the machine;
            # tree-sitter finds them without vcvars, so there is nothing else to install.
            'tree-sitter'

            'lazygit'
            'lazydocker'
            'yazi'
            'zellij'
            # Native arm64, plain. Its TUI cannot open on Windows-on-ARM -- that is an
            # upstream problem, not an architecture to pin around, and x64 under Prism is
            # worse (serve and models die with 0xC0000005 there, silently). Use
            # `opencode serve` + `attach`, or `opencode web`.
            'opencode'

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
            #
            # '=64bit', not a bare pin. The manifest offers arm64, so on a freshly built
            # arm64 machine the bare form fell straight through to the plain `scoop install`
            # and fetched the arm64 build -- no keyboard, on first boot, with the pin sitting
            # right there looking like it had handled it. The forced form is what actually
            # decides the architecture at first install.
            'kanata=64bit'

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

            # opencode is deliberately absent -- its broken TUI is not an architecture
            # problem to pin around. See the note beside it in the install list above.
        )
    }
}
