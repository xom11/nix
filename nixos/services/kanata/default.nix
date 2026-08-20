{
  config,
  lib,
  pkgs,
  mkModule,
  ...
}: let
  # The WHOLE configs/kanata directory into the store, not one file: kanata
  # resolves `include` relative to the cfg file's directory, so its siblings must
  # sit beside it. That is what lets NixOS and Ubuntu share one kanata_linux.kbd --
  # the nixpkgs module takes `config` as a STRING, written to a lone store file
  # with no siblings, which is why a separate nixos variant used to be needed.
  #
  # `configFile` overrides every other module option, including the
  # `linux-continue-if-no-devs-found yes` line the module normally injects; that
  # now lives in the shared defcfg.kbd, which macOS tolerates (verified by
  # `--check`).
  #
  # The module only runs `--check` on files it generates itself, so that step is
  # repeated here rather than lost.
  configDir = pkgs.runCommand "kanata-config" {} ''
    cp -r ${../../../configs/kanata} $out
    chmod -R u+w $out
    ${lib.getExe pkgs.kanata} --cfg $out/kanata_linux.kbd --check --debug
  '';
in
  mkModule config ./. {
    services.kanata = {
      enable = true;
      package = pkgs.kanata;
      keyboards = {
        default = {
          configFile = "${configDir}/kanata_linux.kbd";
        };
      };
    };
  }
