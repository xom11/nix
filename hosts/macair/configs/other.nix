let
  hostname = "macair-qphus";
in
{
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };
  power.sleep = {
    computer = 30;
    display = 30;
    harddisk = 30;
  }
}