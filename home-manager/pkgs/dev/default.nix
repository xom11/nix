{
  config,
  pkgs,
  mkModule,
  ...
}:
mkModule config ./. {
  home.packages = with pkgs; [
    # CLI essentials
    bat
    eza
    fastfetch
    fzf
    gum
    htop
    jq
    ncdu
    ripgrep
    tldr
    tree
    zoxide
    gh
    git
    just

    # Archive
    unrar
    unzip
    zip

    # Network
    cloudflared
    curl
    nmap
    wget

    # System
    util-linux

    # Misc
    discordchatexporter-cli
    yq-go

  ];
}

