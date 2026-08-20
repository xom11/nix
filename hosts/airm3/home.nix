{pkgs, ...}: {
  imports = [
    ../../home-manager
  ];
  home.packages = [
    pkgs.bws
    # beckon comes from Homebrew here, like macmini: `brew upgrade` beats editing
    # flake.lock. NOT to preserve the Accessibility grant -- measured, Homebrew
    # cannot (see nix-darwin/brew). The formula is declared there, so a rebuild
    # taps and installs it; only `brew services start beckon` is manual, once.
    #
    # The `beckon` flake input must STAY: rog and vm still use pkgs.beckon.
    pkgs.tongue
  ];
  modules.home-manager = {
    base = {
      macos.enable = true;
    };
    environments = {
      fonts.enable = true;
    };
    dotfiles = {
      macos = {
        hammerspoon.enable = true;
        sleepwatcher.enable = true;
      };
      terminal = {
        kitty.enable = true;
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
