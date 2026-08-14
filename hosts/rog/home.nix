{ pkgs, ... }:
{
  # Theo khuon hosts/x1g6/home.nix — host nay truoc day chay home-manager
  # standalone tren Ubuntu, tu 14/08/2026 la NixOS that.
  #
  # LD_LIBRARY_PATH da BO. No co mat vi ban Ubuntu: binary tai ngoai nixpkgs
  # (micromamba/conda) khong tu tim thay libstdc++. Ca micromamba lan module
  # conda deu da go 14/08/2026 nen cai co gay ra bien nay khong con, nhung luat
  # thi van dung: dat LD_LIBRARY_PATH o muc phien lam viec la phan tac dung —
  # no ro vao MOI tien trinh con, ke ca binary cua store da co closure dung, va
  # gay loi symbol kieu rat kho truy. Binary ngoai store thieu thu vien thi va
  # bang `programs.nix-ld` hoac mot wrapper rieng, dung dat lai bien toan cuc.
  imports = [
    ../../home-manager
  ];
  modules.home-manager = {
    base = {
      nixos.enable = true;
    };
    dotfiles = {
      ai.enable = true;
      # Nua quyen user cua brave.toml: [shortcuts] + [settings]. [pwa] thi
      # modules.nixos.services.dotbrave ben configuration.nix ghi bang root.
      #
      # Hai dieu khong doc ma biet duoc, ca hai deu im lang khi vap:
      #   - CLI chi ap khi Brave DONG luc activation. Dang mo ma khong co
      #     DevTools endpoint (mac dinh tren Linux -- Brave chi ghi
      #     DevToolsActivePort khi port dong) thi `--unattended` in ke hoach
      #     roi bo qua, ghi 0 byte, thoat 0.
      #   - Entry activation nuot loi (`|| echo ... failed, continuing`), nen
      #     switch xanh KHONG chung minh gi. Phai doc output cua no.
      browser.dotbrave.enable = true;
      terminal.kitty.enable = true;
      # Bat tu 14/08/2026 cung luc voi sway/hyprland. Ghi chu cu o day noi
      # "rofi la X11-only, muon dung phai la rofi-wayland" — dieu do DA SAI:
      # nixpkgs gop hai goi lam mot, `rofi-wayland` gio la alias nem loi
      # ('rofi-wayland' has been merged into 'rofi'), va `pkgs.rofi` chinh la
      # rofi 2.0.0 — ban upstream da nuot fork Wayland. sway.d va hypr.d moi
      # ben goi rofi o 8 cho rieng (drun, combi, window, cliphist, 4 menu
      # nguon) — ca hai session Wayland tren host nay deu can goi nay.
      rofi.enable = true;
    };
    environments = {
      fonts.enable = true;
      gnome.enable = true;
      hyprland.enable = true;
      i18n.enable = true;
      # Bat 14/08/2026 de thu. Bo phim la MAC DINH cua niri chu khong dich tu
      # sway/hyprland, va bo phim launcher (beckon, to hop `Cap`) CHUA duoc noi
      # vao — xem niri.d/config.kdl.
      niri.enable = true;
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
  ];
}
