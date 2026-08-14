{
  pkgs,
  lib,
  username,
  device,
  ...
}:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Ho_Chi_Minh";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN";
    LC_IDENTIFICATION = "vi_VN";
    LC_MEASUREMENT = "vi_VN";
    LC_MONETARY = "vi_VN";
    LC_NAME = "vi_VN";
    LC_NUMERIC = "vi_VN";
    LC_PAPER = "vi_VN";
    LC_TELEPHONE = "vi_VN";
    LC_TIME = "vi_VN";
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "kitty.desktop"
      ];
    };
  };
  environment.systemPackages = with pkgs; [
  ];

  security.polkit.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = username;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      # uinput: can cho che do "Uinput" cua fcitx5-lotus. Lotus co 6 che do
      # (OFF / Uinput Smooth / Uinput Super Smooth / Uinput Slow / Surrounding
      # Text / Preedit) va chi nhom Uinput moi go duoc trong TERMINAL ma khong
      # de lai gach chan -- vi no phat phim that qua /dev/uinput thay vi gui
      # preedit cho app. Terminal khong co surrounding text, nen moi che do
      # khac deu buoc phai preedit (do tren rog 14/08/2026, ke ca khi fcitx5
      # da chay duong Wayland native `protocol: 1` tren Hyprland).
      #
      # KHONG dung cham gi toi kanata: kanata EVIOCGRAB de DOC ban phim that,
      # con lotus chi GHI ra /dev/uinput. Hai chieu nguoc nhau.
      #
      # Nhom chi co hieu luc o PHIEN DANG NHAP MOI. Rebuild xong van phai
      # logout/login, `id -nG` trong phien cu se noi doi la chua co.
      "uinput"
    ];
    initialHashedPassword = "$6$jPRPjdqCcIet/MMB$zUyMpQzb28Oe3D0SdxEk4PwZyoa2iBUfWkonP95rXS3RsI63TQLJOOB3hAZ26YvnNE77Wwoh.vqcmKS540PIu0"; # password is "1"
  };

  # Tao group `uinput` + udev rule cho /dev/uinput. Tren rog no da co san vi
  # `services.kanata` tu bat, nhung host khong chay kanata thi khong -- va
  # `extraGroups` tro toi mot group khong ton tai la loi luc activation chu
  # khong phai luc eval, nen khai o day cho chac.
  hardware.uinput.enable = true;

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  networking.hostName = "${device}-${username}";

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.allowUnfree = true;
  home-manager.backupFileExtension = "backup";

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 7d";
  };

  security.sudo.wheelNeedsPassword = false;

  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
  # mkDefault: gia tri nay dung cho cac host cai tu lau. Host cai moi phai dat
  # lai theo dung phien ban luc cai (rog = 26.05) — stateVersion khong phai so
  # phien ban he thong, no la moc de nixpkgs biet giu hanh vi cu nao cho du
  # lieu da ton tai tren o.
  system.stateVersion = lib.mkDefault "24.11";
}
