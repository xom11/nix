{pkgs, ...}: {
  imports = [
    ../../home-manager
  ];
  home.packages = [
    pkgs.bws
    # beckon: chuyen sang Homebrew, y nhu macmini (17/08/2026). Ly do la
    # `brew upgrade` gon hon "sua flake.lock roi darwin-rebuild".
    #
    # KHONG phai de giu quyen Accessibility: da do 17/08/2026 rang Homebrew
    # KHONG sua duoc chuyen do -- TCC ghi duong dan Cellar co so phien ban va
    # ghim cdhash cua tung ban build, nen moi lan bump van phai cap quyen lai.
    # So do va cach doc TCC.db o nix-darwin/brew, cho khai `xom11/tap/beckon`.
    #
    # Formula duoc KHAI BAO o nix-darwin/brew (tap xom11/tap + brew
    # xom11/tap/beckon), nen `darwin-rebuild switch` tu tap va tu cai; khong
    # con buoc `brew install` tay nao. Con `brew services start beckon` thi
    # van phai chay MOT LAN tren may moi.
    #
    # Input `beckon` trong flake.nix VAN PHAI GIU: rog/vm con dung
    # pkgs.beckon, va gnome dung beckon-gnome-extension.
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
