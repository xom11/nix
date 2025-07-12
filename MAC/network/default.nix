{username}:
let
  hostname = "macmini-${username}";
in
{
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };
}