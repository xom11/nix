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
    home.packages = with pkgs; [
      # conform formatters
      black
      shfmt
      stylua
      alejandra
      prettierd
      yamllint
      yamlfmt
      taplo

      # lsp
      nixd

      tree-sitter
    ];
    programs.nixvim = {
      enable = true;
      # Reuse the host (home-manager) pkgs instead of letting nixvim build
      # its own instance. Avoids an infinite-recursion eval bug triggered by
      # newer nixpkgs when nixvim constructs pkgs via `import nixpkgs.source`.
      # The host pkgs already enables unfree (home-manager/base allowUnfree),
      # so unfree LSPs/plugins still resolve. Note: useGlobalPackages requires
      # nixpkgs.config/overlays to be empty (nixvim assertion).
      nixpkgs.useGlobalPackages = true;
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
