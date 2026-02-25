{
  config,
  ckModule,
  ...
}:
ckModule config ./..
{
  programs.nixvim.plugins = {
    auto-save.enable = true;
    # auto-session.enable = true;
    comment = {
      enable = true;
      settings = {
        pre_hook = "require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()";
      };
    };
    ts-context-commentstring.enable = true;
    friendly-snippets.enable = true;
    luasnip.enable = true;
    nvim-autopairs.enable = true;
    tmux-navigator.enable = true;
    visual-multi.enable = true;
    web-devicons.enable = true;
    neo-tree = {
      enable = true;
      settings = {__raw = "require('opts.neotree')";};
    };
    toggleterm = {
      enable = true;
      settings = {__raw = "require('opts.toggleterm')";};
    };
    which-key = {
      enable = true;
    };
  };
}
