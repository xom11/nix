{pkgs, ...}: {
  imports = [
    ../../home-manager
  ];
  home.packages = [
    pkgs.bws
    # beckon: chuyen sang Homebrew, y nhu macmini (17/08/2026). Ly do khong
    # phai so thich — macOS gan quyen Accessibility/Input Monitoring theo
    # DUONG DAN file, ma duong dan nix store doi moi lan bump, nen moi lan cap
    # nhat la mat quyen. Cellar cung mang so phien ban, nhung
    # /opt/homebrew/opt/beckon/bin/beckon thi on dinh qua cac ban — do la cho
    # treo grant. Ban chat chi het khi binary duoc ky Developer ID.
    #
    # Formula duoc KHAI BAO o nix-darwin/brew (tap xom11/tap + brew
    # xom11/tap/beckon), nen `darwin-rebuild switch` tu tap va tu cai; khong
    # con buoc `brew install` tay nao. Con `brew services start beckon` thi
    # van phai chay MOT LAN tren may moi.
    #
    # Input `beckon` trong flake.nix VAN PHAI GIU: rog/vm/x1g6 con dung
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
