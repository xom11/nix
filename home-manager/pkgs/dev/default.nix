{
  config,
  pkgs,
  mkModule,
  ...
}:
mkModule config ./. {
  home.packages = with pkgs; [
    # CLI essentials
    gum
    htop
    jq
    ncdu
    tldr
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

