{
  lib,
  config,
  pkgs,
  mkModule,
  ...
}:
mkModule config ./. {
  home.packages = with pkgs; [
    # Node.js
    nodejs_22
    nodemon
    pm2
    pnpm
    yarn
    bun
    live-server

    # Python
    python3
    python3Packages.pip
    uv

    # Rust
    maturin
    rustup

    # Go
    go

    # C#
    dotnetCorePackages.sdk_8_0-bin

    # DB tools
    mongosh
  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    # LINUX ONLY, and this `optionals` matters more than the gcc package itself.
    # Measured on macmini: gcc-wrapper on darwin provides 13 binaries whose names
    # collide with Apple's toolchain (cc, ld, as, ar, nm, ...), and the user
    # profile sits ahead of /usr/bin on PATH, so all 13 shadow Apple's.
    #
    # It fails SILENTLY: the home-manager build stays green with no collision
    # warning, and `cc` still compiles a plain C file. The break shows up at the
    # SDK boundary -- `-framework CoreFoundation` fails to find its headers, and
    # `ld` regresses to ld64. Every native build touching a system framework
    # (node-gyp, `*-sys` crates, python C extensions, cgo) breaks on a Mac.
    #
    # Linux needs gcc because `tree-sitter build` shells out to `cc`, which on
    # macOS comes from the Xcode CLT (OUTSIDE nix) -- so no module here ever had to
    # declare it, which is why the gap survived so long. On rog nothing provided
    # `cc`, so every treesitter parser failed to compile, and since install()
    # retries whatever is MISSING, each nvim start re-attempted and re-failed all
    # of them. Measured: 32 errors and 0 parsers per start; with `cc`, 0 errors.
    gcc
  ];

  # npm install -g packages go to ~/.npm-global
  home.sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.npm-global";

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
  ];
}
