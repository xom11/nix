{
  config,
  pkgs,
  mkModule,
  ...
}:
mkModule config ./. {
  home.packages = with pkgs; [
    ansible
    bat
    codespell
    curl
    eza
    fastfetch
    fzf
    git
    gh
    htop
    jq
    ncdu
    ripgrep
    tree
    unrar
    unzip
    util-linux
    vim
    wget
    zip
    zoxide

    # Tui
    gobang
    lazydocker
    lazygit
    # mongo-tui

    # Rust
    maturin
    rustup

    # Python
    python3
    python3Packages.pip
    uv
    # micromamba
    # mamba

    # Node.js
    nodejs.pkgs.nodemon
    nodejs.pkgs.npm
    nodejs.pkgs.pm2
    nodejs.pkgs.yarn
    bun
    live-server

    # C-sharp
    dotnetCorePackages.sdk_8_0-bin

    # golang
    go

    # mongo
    mongosh

    # Other
    # ffmpeg
    tldr

    # BUG: conflicts with macOS clang
    # https://github.com/NixOS/nixpkgs/issues/306279#issuecomment-2634075103
    # gcc

    ripdrag

    # network
    nmap
  ];
}
