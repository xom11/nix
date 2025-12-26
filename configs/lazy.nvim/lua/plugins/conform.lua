return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" }, 
  cmd = { "ConformInfo" },
  dependencies = {
    "williamboman/mason.nvim",
  },
  config = function()
    local conform = require("conform")

    conform.setup({
      notify_on_error = true,
      formatters_by_ft = {
        html = { { "prettierd", "prettier" } },
        css = { { "prettierd", "prettier" } },
        scss = { "prettierd", "prettier" },
        javascript = { { "prettierd", "prettier" } },
        javascriptreact = { { "prettierd", "prettier" } },
        typescript = { { "prettierd", "prettier" } },
        typescriptreact = { { "prettierd", "prettier" } },
        markdown = { { "prettierd", "prettier" } },
        yaml = { { "yamllint", "yamlfmt" } },
        json = { "prettierd" },
        nix = { "alejandra" },
        lua = { "stylua" },
        python = { "black" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        ["_"] = { "trim_whitespace" },
      },
      format_on_save = false, 
    })

    vim.keymap.set("n", "<leader>lf", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      })
    end, { silent = true, desc = "Format file" })
  end,
}
