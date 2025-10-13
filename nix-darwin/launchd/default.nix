{pkgs, ...}:
{
  launchd.agents."kanata.plist" = {
    command = "${pkgs.kanata} -c ${./kanata.kbd}";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/Library/Logs/Kanata/kanata.out.log";
      StandardErrorPath = "/Library/Logs/Kanata/kanata.err.log";
    };
  };
}