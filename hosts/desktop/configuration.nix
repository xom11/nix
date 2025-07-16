{ config, lib, pkgs, ... }:

{
  config = {
    imports = [
      ../../LINUX/base
      ../../LINUX/services
    ]
  };
}