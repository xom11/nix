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
      # The seam of the hybrid setup: nixvim owns the LSP config, Lua owns the
      # completion engine, and nothing wired them together -- servers never
      # learned what nvim-cmp supports. pcall because plugins/cmp.lua fetches
      # cmp-nvim-lsp at runtime and may not have loaded.
      capabilities = ''
        local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        if ok then
          capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
        end
      '';
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
