require("nvim-treesitter.configs").setup({
    -- auto install
    auto_install = true,
    -- add language you want to highlight in code
    ensure_installed = {
        "c",
        "lua",
        "vim",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "java",
        "json",
        "zig",
    },
    sync_install = false,
    highlight = { enable = true },
    indent = { enable = true },
})