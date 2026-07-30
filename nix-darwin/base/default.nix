
{ pkgs, lib, username, ... }:
{
  # enable flakes globally
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.package = pkgs.nix;

  # Garbage-collect daily, not weekly. nix-darwin defaults to Weekday = 7
  # (Sunday only), which is far too sparse here: macmini rebuilds ~1.5x/day, so
  # 22 system generations piled up over 14 days and /nix/store reached 52G.
  # Every `darwin-rebuild switch` also rewrites and reloads this plist, which
  # resets launchd's calendar tracking -- one more reason not to rely on a
  # once-a-week slot. Omitting Weekday makes it fire every day.
  nix.gc = {
    automatic = lib.mkDefault true;
    interval = lib.mkDefault {
      Hour = 3;
      Minute = 15;
    };
    options = lib.mkDefault "--delete-older-than 3d";
  };

  # Disable auto-optimise-store because of this issue:
  #   https://github.com/NixOS/nix/issues/7273
  # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
  nix.settings = {
    auto-optimise-store = false;
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = username;
  system.stateVersion = 6;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    home = "/Users/${username}";
    description = username;
  };

  security.sudo.extraConfig = ''
    ${username} ALL=(ALL) NOPASSWD: ALL
  '';

  nix.settings.trusted-users = [username];


}