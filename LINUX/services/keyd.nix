{ config, lib, pkgs, ... }:
{
  environment = {
    etc = {
      "keyd/default.conf".text = ''
        [main]
        capslock=overload(hyper, esc)
        [hyper:C-M-A]
      '';
    };
    # systemPackages = [
  };

}