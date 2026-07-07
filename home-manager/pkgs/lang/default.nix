{
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
  ];

  # npm install -g packages go to ~/.npm-global
  home.sessionVariables.NPM_CONFIG_PREFIX = "$HOME/.npm-global";

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
  ];
}
