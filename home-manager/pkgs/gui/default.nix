{pkgs, lib, config, ...}:
let
  cfg = config.modules.pkgs.gui;
in
{
  options.modules.pkgs.gui = {
    enable = lib.mkEnableOption "Install common GUI packages";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      bitwarden-desktop
      deskreen
      qutebrowser
      discord
      nemo
      vscode
      telegram-desktop
      localsend
      slack
      google-chrome
      kitty
      caprine
      vlc
    ];
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
      "--start-fullscreen"
      ];
    };
  };
}

