{pkgs, ...}:
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
      ];
    };
}