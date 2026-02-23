{
  config,
  pkgs,
  ckModule,
  ...
}:
ckModule config ./..
{
  programs.nixvim.plugins = {
    lsp = {
      enable = true;
      servers = {
        pyright = {
          enable = true;
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "off";
                autoSearchPaths = true;
                useLibraryCodeForTypes = true;
              };
            };
          };
        };
        nixd.enable = true; # Nix
        jsonls.enable = true; # JSON
        yamlls.enable = true; # YAML
        marksman.enable = true; # Markdown
        ts_ls.enable = true; # TS/JS
        cssls.enable = true; # CSS
        tailwindcss.enable = true; # TailwindCSS
        html.enable = true; # HTML
        astro.enable = true; # AstroJS
        phpactor.enable = true; # PHP
        svelte.enable = false; # Svelte
        dockerls.enable = true; # Docker
        bashls.enable = true; # Bash
        clangd.enable = true; # C/C++
        # csharp_ls.enable = true; # C#
        gopls.enable = true; # Go

        lua_ls = {
          enable = true;
          settings.telemetry.enable = false;
        };
        emmet_language_server.enable = true; # Emmet

        rust_analyzer = {
          enable = true;
          installRustc = true;
          installCargo = true;
        };
      };
      keymaps = {
        silent = true;
        lspBuf = {
          # gd = {
          #   action = "definition";
          #   desc = "Go to Definition";
          # };
          # gr = {
          #   action = "references";
          #   desc = "Go to References";
          # };
          # gD = {
          #   action = "declaration";
          #   desc = "Go to Declaration";
          # };
          "<leader>rn" = {
            action = "rename";
            desc = "Rename";
          };
        };
      };
    };
  };
  home.packages = with pkgs; [
    nixd
  ];
}
