{ config
, pkgs
, inputs
, lib
, ...
}:
{
  environment.systemPackages = with pkgs;
    [
    gnomeExtensions.run-or-raise

    ];
  

}