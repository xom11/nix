{
  config,
  ckModule,
  ...
}:
ckModule config ./..
{
  programs.nixvim.plugins = {
    gitsigns = {
      enable = true;
      settings = {__raw = "require('opts.gitsigns')";};
    };

    # https://github.com/sindrets/diffview.nvim/
    diffview = {
      enable = true;
    };

    lazygit = {
      enable = true;
    };
  };
}
