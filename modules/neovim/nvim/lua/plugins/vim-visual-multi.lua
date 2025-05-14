-- file: ~/.config/nvim/lua/plugins/editor.lua (hoặc file plugins tương ứng)
return {
  {
    "mg979/vim-visual-multi",
    keys = {
      { "<C-n>", mode = { "n", "x" } }, -- Ánh xạ Ctrl+N
    },
    init = function()
      -- Có thể thêm cấu hình khởi tạo nếu cần
    end,
  },
}
