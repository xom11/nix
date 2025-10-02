{ config, pkgs, lib, ... }:
let
  cfg = config.modules.pkgs.dev;
in
{
  options.modules.pkgs.dev = {
    enable = lib.mkEnableOption "Install development tools";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fastfetch
      vim
      # htop
      btop
      lazygit
      lazydocker
      zip
      unzip
      unrar
      wget
      curl
      tree
      fzf
      bat
      eza
      yazi
      yaziPlugins.smart-enter
      zoxide
      ncdu
      jq
      gh
      ripgrep
      ansible

      # Database
      minio-client

      # Rust
      maturin
      rustup

      # Python
      python3
      python3Packages.pip
      uv
      micromamba

      # Node.js
      nodejs.pkgs.npm
      nodejs.pkgs.yarn
      nodejs.pkgs.nodemon
      nodejs.pkgs.pm2

      # Other
      tldr
      ffmpeg
      gcc
    ];
  };
}