{ pkgs, ... }:
{
  # Theo khuon hosts/x1g6/home.nix — host nay truoc day chay home-manager
  # standalone tren Ubuntu, tu 14/08/2026 la NixOS that.
  #
  # LD_LIBRARY_PATH da BO. No co mat vi ban Ubuntu: binary tai ngoai nixpkgs
  # (micromamba/conda) khong tu tim thay libstdc++. Tren NixOS dat bien do o
  # muc phien lam viec la phan tac dung — no ro vao MOI tien trinh con, ke ca
  # binary cua store da co closure dung, va gay loi symbol kieu rat kho truy.
  # Neu conda hong that thi vá bang `programs.nix-ld` hoac mot wrapper rieng,
  # dung dat lai bien toan cuc.
  imports = [
    ../../home-manager
  ];
  modules.home-manager = {
    base = {
      nixos.enable = true;
    };
    dotfiles = {
      ai.enable = true;
      terminal.kitty.enable = true;
      conda.enable = true;
      # Bat tu 14/08/2026 cung luc voi sway/hyprland. Ghi chu cu o day noi
      # "rofi la X11-only, muon dung phai la rofi-wayland" — dieu do DA SAI:
      # nixpkgs gop hai goi lam mot, `rofi-wayland` gio la alias nem loi
      # ('rofi-wayland' has been merged into 'rofi'), va `pkgs.rofi` chinh la
      # rofi 2.0.0 — ban upstream da nuot fork Wayland. sway.d goi rofi o 8 cho
      # (drun, combi, window, cliphist, 4 menu nguon).
      rofi.enable = true;
    };
    environments = {
      fonts.enable = true;
      gnome.enable = true;
      i18n.enable = true;
      sway.enable = true;
      wayland.enable = true;
    };
    pkgs = {
      dev.enable = true;
      lang.enable = true;
      tools.enable = true;
      nixos.enable = true;
    };
    programs = {
      # agenix CO Y khong bat, khac x1g6. Chu may quyet dinh host nay khong can
      # secret (14/08/2026). He qua co that: module ssh boc `age.secrets` trong
      # `lib.mkIf agenixEnabled`, nen ~/.ssh/age.d/config khong duoc tao va
      # dong `Include ~/.ssh/age.d/*` trong programs/ssh/config khong khop gi.
      # ssh van chay binh thuong -- Include khong khop la khong loi.
      #
      # Keo theo: khoa cua rog KHONG duoc them vao programs/ssh/authorized_keys,
      # nen no cung khong phai recipient agenix (keys.nix sinh tu file do).
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
  home.packages = [
    pkgs.beckon
    pkgs.bws
    # Giu lai tu ban standalone thoi con chay Ubuntu.
    pkgs.discordchatexporter-cli
    pkgs.micromamba
  ];
}
