{
  config,
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
        nixd.enable = true;
        jsonls.enable = true;
        yamlls.enable = true;
        marksman.enable = true;
        ts_ls.enable = true;
        cssls.enable = true;
        tailwindcss.enable = true;
        html.enable = true;
        astro.enable = true;
        phpactor.enable = true;
        svelte.enable = false;
        dockerls.enable = true;
        bashls.enable = true;
        clangd.enable = true;
        gopls.enable = true;
        lua_ls = {
          enable = true;
          settings.telemetry.enable = false;
        };
        emmet_language_server.enable = true;
        rust_analyzer = {
          enable = true;
          installRustc = true;
          installCargo = true;
        };
      };
      keymaps = {
        silent = true;
        lspBuf = {
          "<leader>rn" = {
            action = "rename";
            desc = "Rename";
          };
        };
      };
    };
  };
}
