{ pkgs, device, lib, ... }:
lib.mkIf (device == "x1g6") 
{
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
}