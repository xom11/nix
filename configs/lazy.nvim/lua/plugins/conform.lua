return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "zapling/mason-conform.nvim",
  },
  config = function()
    local conform = require("conform")
    local mason_conform = require("mason-conform")

    mason_conform.setup({
      ensure_installed = {
        -- "black",
        -- "shfmt",
        -- "stylua",
        -- "prettierd",
        -- "prettier",
        -- "yamllint",
        -- "yamlfmt",
      },
    })

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
