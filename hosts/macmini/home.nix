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
    # beckon: chuyen sang Homebrew 17/08/2026. Ly do khong phai so thich —
    # macOS gan quyen Accessibility/Input Monitoring theo DUONG DAN file, va
    # duong dan nix store doi moi lan bump, nen moi lan cap nhat la mat quyen.
    # Homebrew khong sua duoc dieu do (Cellar cung mang so phien ban), nhung
    # `brew upgrade` + `brew services` la mot buoc, con o day la sua flake.lock
    # roi darwin-rebuild. Ban chat chi het khi binary duoc ky Developer ID.
    # Tu 17/08/2026 formula duoc KHAI BAO o nix-darwin/brew (tap xom11/tap +
    # brew xom11/tap/beckon) — truoc do may nay cai bang tay nen nam ngoai
    # khai bao. Chi con `brew services start beckon` la chay tay mot lan.
    # Truoc 16/08/2026 binary nay den tu module dotbrave (`home.packages =
    # [cfg.package]` cua module upstream). Module da go, nen phai khai o day --
    # neu khong thi `dotbrave` bien mat khoi PATH va het ap tay duoc.
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
      # Tat cung luc chuyen sang Homebrew: formula tu ship launch agent
      # (`service do`), nen de bat o day la hai agent cung dang ky mot chord —
      # `RegisterEventHotKey` trao cho ai dang ky TRUOC, ban thu hai im lang.
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
