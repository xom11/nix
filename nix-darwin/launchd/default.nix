{dotfileDir, ...}:
{
  # https://github.com/jtroo/kanata/discussions/1537
  launchd.daemons."kanata" = {
    command = "/opt/homebrew/bin/kanata -c /etc/kanata/kanata.kbd";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/Library/Logs/Kanata/kanata.out.log";
      StandardErrorPath = "/Library/Logs/Kanata/kanata.err.log";
    };
  };
  environment.etc."kanata/kanata.kbd".source = "${dotfileDir}/kanata/kanata.kbd";
}