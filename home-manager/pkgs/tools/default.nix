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

    # Archive
    unrar
    unzip
    zip

    # Network
    cloudflared
    curl
    nmap
    wget

    # Editor
    vim

    # System
    util-linux

    # Misc
    caligula
    discordchatexporter-cli
    yq-go

    # Secrets
    age
    gnupg
    mkpasswd
    pass
  ];
}
