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
    # Ollama
    OLLAMA_MODELS = "${ssd}/ollama/models";
  };

  home.packages = with pkgs; [
    bws
    # dotbrave came from its own module until that was removed; declared here or
    # the binary leaves PATH and there is no way to apply by hand.
    # (beckon itself comes from Homebrew -- see nix-darwin/brew for why.)
    dotbrave
    tongue
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
      macos = {
        hammerspoon.enable = true;
        sleepwatcher.enable = true;
      };
      ai.enable = true;
    };
    pkgs = {
      dev.enable = true;
      lang.enable = true;
      tools.enable = true;
    };
    programs = {
      agenix.enable = true;
      # Off since beckon moved to Homebrew: the formula ships its own launch
      # agent, and two agents on one chord means RegisterEventHotKey gives it to
      # whoever registered FIRST while the second fails silently.
      beckon-serve.enable = false;
      btop.enable = true;
      git.enable = true;
      herdr.enable = true;
      nvim.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      yazi.enable = true;
      zsh.enable = true;
    };
  };
}
