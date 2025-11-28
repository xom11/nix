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
    gh
    htop
    jq
    lazydocker
    lazygit
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

    # C-sharp
    dotnetCorePackages.sdk_8_0-bin

    # golang
    go

    # Other
    ffmpeg
    tldr

    # BUG: conflicts with macOS clang
    # https://github.com/NixOS/nixpkgs/issues/306279#issuecomment-2634075103
    # gcc
  ];
}
