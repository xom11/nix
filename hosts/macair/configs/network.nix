let
  hostname = "macair-qphus";
in
{
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };
}