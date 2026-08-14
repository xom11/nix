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
      # rofi KHONG bat, khac x1g6: rofi la X11-only va host nay chay GNOME tren
      # Wayland. Muon launcher rieng thi phai la rofi-wayland, khong phai rofi.
    };
    environments = {
      fonts.enable = true;
      gnome.enable = true;
      i18n.enable = true;
    };
    pkgs = {
      dev.enable = true;
      lang.enable = true;
      tools.enable = true;
      nixos.enable = true;
    };
    programs = {
      # agenix BAT tu 14/08/2026 (dao lai quyet dinh cung ngay truoc do). Khoa
      # cong khai cua may nay da vao programs/ssh/authorized_keys, ma keys.nix
      # sinh tu chinh file do -- nen rog la recipient agenix, va hai file .age
      # trong cay da duoc rekey lai cho du 5 nguoi nhan.
      #
      # Khac macOS: agent giai ma tren Linux la systemd oneshot KHONG co
      # `Restart=`, nen no khong tu thu lai nhu launchd. Lan switch dau tren mot
      # may vua co khoa moi, neu secret chua ra thi chay tay `agenix-reload`.
      agenix.enable = true;
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
