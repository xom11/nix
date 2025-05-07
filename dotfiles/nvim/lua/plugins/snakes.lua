return -- lazy.nvim
{
  "folke/snacks.nvim",
  ---@type snacks.Config

  opts = {
    explorer = {},
    picker = {
      sources = {
        explorer = {
          layout = { layout = { position = "right" } },
        },
        files = {
          hidden = true,
        },
      },
    },
  },
}
