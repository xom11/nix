{pkgs, ...}:
{
    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      extensions = [
      ];
      commandLineArgs = [
        "--enable-features=ParallelDownloading"
        "--extensions-on-chrome-urls"
      ];
    };
}