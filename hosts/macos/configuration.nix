
{ config, pkgs, ... }:
let user = builtins.getEnv "USER"; in

{
  imports = [
    ../../modules/fonts
  ];
  environment.systemPackages =[
    pkgs.vim
    ];

  nix.settings.experimental-features = "nix-command flakes";
  programs.zsh.enable = true; 
  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    # Turn off NIX_PATH warnings now that we're using flakes
    checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 6;
    defaults = {
      # LaunchServices = {
      #   LSQuarantine = false;
      # };
      # NSGlobalDomain = {
      #   AppleShowAllExtensions = true;
      #   ApplePressAndHoldEnabled = false;

      #   # 120, 90, 60, 30, 12, 6, 2
      #   KeyRepeat = 2;

      #   # 120, 94, 68, 35, 25, 15
      #   InitialKeyRepeat = 15;
      #   "com.apple.mouse.tapBehavior" = 1;
      #   "com.apple.sound.beep.volume" = 0.0;
      #   "com.apple.sound.beep.feedback" = 0;
      # };
      dock = {
        autohide = false;
        # show-recents = false;
        # launchanim = true;
        # mouse-over-hilite-stack = true;
        orientation = "bottom";
        # tilesize = 48;
      };
    #   finder = {
    #     _FXShowPosixPathInTitle = false;
    #   };
    #   trackpad = {
    #     Clicking = true;
    #     TrackpadThreeFingerDrag = true;
    #   };
    };
    # keyboard = {
    #   enableKeyMapping = true;
    #   remapCapsLockToControl = true;
    # };
  };
}