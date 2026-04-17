{
  lib,
  config,
  pkgs,
  mkModule,
  getPath,
  ...
}: let
  inherit (builtins) filter map toString;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasSuffix;
  pwd = getPath ./.;
in
  {
    imports = filter (hasSuffix ".nix") (
      map toString (filter (p: p != ./default.nix) (listFilesRecursive ./.))
    );
  }
  // mkModule config ./. {
    programs.nixvim = {
      enable = true;
      nixpkgs.config.allowUnfree = true;
      extraConfigLuaPre = ''
        -- Add the current directory to runtime path to load extra Lua configs
        vim.opt.rtp:append("${pwd}")

        require('config.options')
        require('plugins')
      '';

      extraConfigLuaPost = ''
        require('config.keymaps')
        require('extras')
      '';
    };
  }
