{ pkgs, device, ...}:
let
  ssd = "/Volumes/ssd";
in
{
  nixpkgs.overlays = [
    (import ../../overlays)
  ];
  imports = [
    ../../home-manager
  ];
  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#${device}";
  };
  home.sessionVariables = {
    # Homebrew
    HOMEBREW_CACHE = "${ssd}/cache/Homebrew";
    # uv
    UV_CACHE_DIR = "${ssd}/cache/uv";
    UV_DATA_DIR  = "${ssd}/data/uv";
    # npm
    NPM_CONFIG_CACHE = "${ssd}/cache/npm";
    # Colima/Lima VM disk
    LIMA_HOME = "${ssd}/lima";
    # HuggingFace (models + datasets)
    HF_HOME = "${ssd}/huggingface";
    # PyTorch
    TORCH_HOME = "${ssd}/cache/torch";
    # Selenium drivers
    SE_CACHE_DIR = "${ssd}/cache/selenium";
    # pip
    PIP_CACHE_DIR = "${ssd}/cache/pip";
    # .NET / NuGet
    NUGET_PACKAGES = "${ssd}/data/NuGet";
    # Prisma engines
    PRISMA_ENGINES_CACHE_DIR = "${ssd}/cache/prisma";
    # micromamba
    MAMBA_ROOT_PREFIX = "${ssd}/micromamba";
  };

  home.packages = with pkgs; [
    bws
    # fcitx5-macos
    # neofetch2
  ];

  modules.home-manager = {
    environments = {
      fonts.enable = true;
    };
    dotfiles = {
      # aerospace.enable = true;
      ai.enable = true;
      conda.enable = true;
      hammerspoon.enable = true;
      # karabiner.enable = true;
      kitty.enable = true;
      qutebrowser.enable = true;
      secrets.enable = true;
      sleepwatcher.enable = true;
      vscode.enable = true;
      firefox.enable = true;
    };
    pkgs = {
      dev.enable = true;
      test.enable = true;
    };
    programs = {
      btop.enable = true;
      git.enable = true;
      lazyvim.enable = true;
      nixvim.enable = true;
      nvim.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      yazi.enable = true;
      zsh.enable = true;
    };
    services = {
      # syncthing.enable = true;
    };
  };
}
