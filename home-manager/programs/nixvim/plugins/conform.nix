{
  pkgs,
  config,
  ckModule,
  ...
}:
ckModule config ./..
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
        "_" = ["trim_whitespace"];
        bash = ["shfmt"];
        css = ["prettierd" "prettier"];
        html = ["prettierd" "prettier"];
        javascript = ["prettierd" "prettier"];
        javascriptreact = ["prettierd" "prettier"];
        json = ["prettierd"];
        lua = ["stylua"];
        markdown = ["prettierd" "prettier"];
        nix = ["alejandra"];
        python = ["black"];
        rust = ["rustfmt"];
        scss = ["prettierd" "prettier"];
        sh = ["shfmt"];
        toml = ["taplo"];
        typescript = ["prettierd" "prettier"];
        typescriptreact = ["prettierd" "prettier"];
        yaml = ["yamllint" "yamlfmt"];
      };
    };
    luaConfig.post = ''
      vim.keymap.set("n", "<leader>lf", function()
        require("conform").format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 500,
        })
      end, { silent = true, desc = "Format file" })
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
    taplo
  ];
}
