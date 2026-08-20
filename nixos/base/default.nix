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
      # uinput is for fcitx5-lotus's Uinput modes, the only ones that type in a
      # TERMINAL without underlining: they inject real keys through /dev/uinput
      # instead of sending preedit, and a terminal has no surrounding text so
      # every other mode is forced back to preedit.
      #
      # Does NOT collide with kanata: kanata EVIOCGRABs to READ the keyboard,
      # lotus only WRITES to /dev/uinput. Opposite directions.
      #
      # Group membership only applies to a NEW login session -- `id -nG` in the
      # current one will keep saying it is missing after a rebuild.
      "uinput"
    ];
    initialHashedPassword = "$6$jPRPjdqCcIet/MMB$zUyMpQzb28Oe3D0SdxEk4PwZyoa2iBUfWkonP95rXS3RsI63TQLJOOB3hAZ26YvnNE77Wwoh.vqcmKS540PIu0"; # password is "1"
  };

  # Creates the `uinput` group and its udev rule. kanata enables this itself, but
  # a host without kanata would not have it -- and `extraGroups` naming a
  # nonexistent group fails at activation, not at eval.
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
  # mkDefault: this value is for the older hosts. A newly installed host must set
  # its own -- stateVersion is not a system version, it is the marker telling
  # nixpkgs which legacy behaviour to keep for data already on disk.
  system.stateVersion = lib.mkDefault "24.11";
}
