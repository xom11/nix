let
  hostname = "macmini-kln";
in
{
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };
}