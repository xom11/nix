{
  pkgs,
  config,
  ckModule,
  ...
}:
ckModule config ./.
{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    settings = {
      # turn off format on save
      # format_on_save = {
      #   lspFallback = true;
      #   timeoutMs = 500;
      # };
      notify_on_error = true;
      formatters_by_ft = {
        html = [["prettierd" "prettier"]];
        css = [["prettierd" "prettier"]];
        scss = ["prettierd" "prettier"];
        javascript = [["prettierd" "prettier"]];
        javascriptreact = [["prettierd" "prettier"]];
        typescript = [["prettierd" "prettier"]];
        typescriptreact = [["prettierd" "prettier"]];
        markdown = [["prettierd" "prettier"]];
        yaml = [["yamllint" "yamlfmt"]];
        json = ["prettierd"];
        nix = ["alejandra"];
        lua = ["stylua"];
        python = ["black"];
        rust = ["rustfmt"];
        sh = ["shfmt"];
        bash = ["shfmt"];
        "_" = ["trim_whitespace"];
      };
    };
    luaConfig.post = ''
      local map = vim.keymap.set
      map.{'n', 'lf', function()
        require('conform').format({ lsp_fallback = true, async = false, timeout_ms = 500 })
      end, { desc = "Format with Conform" })
    '';
  };
  home.packages = with pkgs; [
    black
    shfmt
    stylua
    alejandra
    prettierd
    yamllint
    yamlfmt
  ];
}
