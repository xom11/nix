{
  config,
  pkgs,
  agenix,
  system,
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
    worktrunk
    gum
    just

    # Tui
    # gobang
    lazydocker
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
    nodemon
    nodejs_22
    pm2
    pnpm
    yarn
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
    caligula
    discordchatexporter-cli
    yq-go
    hugo

    # BUG: conflicts with macOS clang
    # https://github.com/NixOS/nixpkgs/issues/306279#issuecomment-2634075103
    # gcc

    ripdrag

    # network
    nmap
    cloudflared

    # secrets
    age
    gnupg
    pass
    mkpasswd
  ] ++ [
    agenix.packages.${system}.default
  ];

  # ──────────────────────────────────────────────
  # npm install -g via nix
  #
  # nix's npm không thể ghi vào nix-store (read-only).
  # Giải pháp: set NPM_CONFIG_PREFIX = ~/.npm-global
  # để npm ghi global packages vào thư mục user.
  #
  # Sau khi chạy `npm install -g <pkg>`,
  # binary sẽ nằm ở ~/.npm-global/bin và được
  # thêm vào PATH qua home.sessionPath.
  #
  # Cách dùng:
  #   npm install -g typescript
  #   # → typescript compiler ở ~/.npm-global/bin
  #   npx tsc --version
  #
  # Nếu cần chạy thường xuyên, nên dùng nix's
  # nodePackages thay vì npm install -g.
  # ──────────────────────────────────────────────

  home.sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.npm-global";

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
  ];
}
