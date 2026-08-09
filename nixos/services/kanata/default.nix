{
  config,
  pkgs,
  mkModule,
  ...
}: let
  # Path literal, KHONG phai "${repoPath}/configs/kanata".
  #
  # `builtins.readFile` chay luc EVAL, nen dung repoPath khong he cho phep
  # "sua .kbd ma khong rebuild" -- doi nao cung phai switch. Doi lai no bien
  # duong dan tuyet doi ngoai flake (`~/.nix/...`) thanh dau vao cua eval, nen
  # bat host len la chi con eval duoc TREN DUNG MAY DO:
  #   error: path '/home/<user>/.nix/configs/kanata/kanata_nixos.kbd' does not exist
  # CI va moi may khac deu do. Do la ly do `kanata.enable` bi comment o ca
  # hosts/x1g6 lan hosts/vm. Path literal copy vao store nen eval o dau cung
  # duoc -- giong het system-manager/services/kanata da lam.
  configFile =
    builtins.readFile ../../../configs/kanata/kanata_nixos.kbd
    + builtins.readFile ../../../configs/kanata/main.kbd;
in
  mkModule config ./. {
    services.kanata = {
      enable = true;
      package = pkgs.kanata;
      keyboards = {
        default = {
          # match the shared defcfg.kbd the other platforms include
          extraDefCfg = "process-unmapped-keys yes";
          config = configFile;
        };
      };
    };
  }
