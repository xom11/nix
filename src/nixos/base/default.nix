{input, config, pkgs, lib, username, device, ... }:
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

  services.xserver.enable = true;
  # GNOME 
  # services.displayManager.gdm.enable = true;
  # services.desktopManager.gnome.enable = true;
  # services.gnome.core-apps.enable = false;
  # services.gnome.gnome-keyring.enable = true;
  # KDE
  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;
  # services.desktopManager.plasma6.enable = true;
  # Sway
  # programs.sway = {
  #   enable = true;
  #   wrapperFeatures.gtk = true;
  # };
  # i3
  services.xserver.windowManager.i3.enable = true;

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
  services.displayManager.autoLogin.user = "kln";

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
    extraGroups = [ "networkmanager" "wheel" ];
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
