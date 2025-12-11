{
  config,
  ckModule,
  ...
}:
# Toggle teminall for nvim
ckModule config ./..
{
  programs.nixvim.plugins = {
    toggleterm = {
      enable = true;
      settings = {
        direction = "float";
        float_opts = {
          border = "curved";
          height = "
            function()
              return math.floor(vim.o.lines * 0.8)
            end
            ";
          width = "
            function()
              return math.floor(vim.o.columns * 0.8)
            end
            ";
        };
        open_mapping = "[[<a-t>]]";
      };
    };
  };
}
