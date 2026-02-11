{
  config,
  ckModule,
  ...
}:
# Keymap Tab (cmp.nix)
ckModule config ./..
{
  programs.nixvim.plugins = {
    todo-comments = {
      enable = true;
      settings = {__raw = "require('opts.todo-comments')";};
    };

    # https://github.com/ThePrimeagen/harpoon/
    # mark files and quickly navigate between them
    harpoon = {
      enable = true;
    };

    nvim-surround = {
      enable = true;
      settings = {__raw = "require('opts.nvim-surround')";};
    };

    flash = {
      enable = true;
      settings = {__raw = "require('opts.flash')";};
    };
  };
}
