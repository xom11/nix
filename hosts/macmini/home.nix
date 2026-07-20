{pkgs, ...}: let
  ssd = "/Volumes/ssd";
in {
  imports = [
    ../../home-manager
  ];
  home.sessionVariables = {
    # Homebrew
    HOMEBREW_CACHE = "${ssd}/cache/Homebrew";
    # uv
    UV_CACHE_DIR = "${ssd}/cache/uv";
    UV_DATA_DIR = "${ssd}/data/uv";
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
    # Ollama
    OLLAMA_MODELS = "${ssd}/ollama/models";
  };

  home.packages = with pkgs; [
    bws
    beckon
    # fcitx5-macos
    # neofetch2
  ];

  modules.home-manager = {
    base = {
      macos.enable = true;
    };
    environments = {
      fonts.enable = true;
    };
    dotfiles = {
      terminal = {
        kitty.enable = true;
      };
      browser = {
        # qutebrowser.enable = true;
        # firefox.enable = true;
        # dotbrowser = {
        #   vivaldi.enable = true;
        #   brave.enable = true;
        # };
      };
      macos = {
        hammerspoon.enable = true;
        # karabiner.enable = true;
        sleepwatcher.enable = true;
      };
      ai.enable = true;
      conda.enable = true;
      vscode.enable = true;
    };
    pkgs = {
      dev.enable = true;
      lang.enable = true;
      tools.enable = true;
    };
    programs = {
      btop.enable = true;
      git.enable = true;
      herdr.enable = true;
      nvim.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      yazi.enable = true;
      zsh.enable = true;
    };
    services = {
      # syncthing.enable = true;
    };
    programs = {
      agenix.enable = true;
    };
  };
}
