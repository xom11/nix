{ pkgs, device, lib, ... }:
lib.mkIf (device == "x1g6") 
{
  home.packages = with pkgs;[
    # CLI
    tldr
    gemini-cli
    gcc
    caligula
    feh
    rofi

    # GUI
    bitwarden-desktop
    qutebrowser
    nautilus
    discord
    vscode
    telegram-desktop
    localsend
    slack
    google-chrome
    kitty
    caprine
    vlc
  ];
    # services.flatpak.packages = [
    # { appId = "com.simplenote.Simplenote"; origin = "flathub"; }
  # ];
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } # vimium c
      { id = "nacjakoppgmdcpemlfnfegmlhipddanj"; } # pdf for vimium c
    ];
    commandLineArgs = [
      "--enable-features=ParallelDownloading"
      "--extensions-on-chrome-urls"
    ];
  };

  home.shellAliases = {
    update = ''
      git -C ~nix pull
      sudo nixos-rebuild switch --impure --refresh --flake ~/.nix#x1g6
    '';
  };
}