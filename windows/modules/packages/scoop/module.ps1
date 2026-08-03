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
            'aichat'
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

            # The TUI is OpenTUI, which loads its native render library through
            # `bun:ffi` dlopen(). Bun's Windows arm64 build ships with TinyCC disabled, so
            # dlopen() does not exist there and every launch dies immediately with
            # "Failed to initialize OpenTUI render library". Upstream build limitation --
            # nothing in this repo can work around it.
            #
            # What makes it worth a comment is how selective the breakage looks: `opencode
            # run`, `serve`, and every `debug` subcommand work fine on the arm64 build,
            # because none of them touch the renderer. Measured on a14 -- `opencode debug
            # startup` returned in 560ms on the same install that could not open the TUI at
            # all. So the obvious first suspects are config and symlinks, and both are
            # innocent.
            #
            # Runs under Prism emulation instead. opencode spends its time waiting on the
            # network, so the emulation cost is not worth chasing.
            #
            # '=64bit' rather than a bare pin: a bare pin only holds an existing install
            # still, so a freshly built arm64 machine would install the arm64 build and then
            # be pinned to the one that cannot open.
            'opencode=64bit'
        )
    }
}
