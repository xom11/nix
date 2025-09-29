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
    ];
    initialHashedPassword = "$6$jPRPjdqCcIet/MMB$zUyMpQzb28Oe3D0SdxEk4PwZyoa2iBUfWkonP95rXS3RsI63TQLJOOB3hAZ26YvnNE77Wwoh.vqcmKS540PIu0"; # password is "1"
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  programs.firefox.enable = true;
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
  system.stateVersion = "24.11";
}
