{
  config,
  ckModule,
  ...
}:
ckModule config ./..
{
  programs.nixvim.plugins = {
    lualine = {
      enable = true;
    };
    render-markdown = {
      enable = true;
      settings = {__raw = "require('opts.render-markdown').opts";};
    };
    dashboard.enable = true;
    colorizer.enable = true;
    noice.enable = true;
    image.enable = true;
    barbecue.enable = true;
    notify = {
      enable = true;
      luaConfig.post = ''
        local t = require('opts.nvim-notify')
        t.config(nil, t.opts)
      '';
      settings = {__raw = "require('opts.nvim-notify').opts";};
    };
    transparent = {
      enable = true;
      luaConfig.post = ''
        local t = require('opts.transparent')
        t.config(nil, t.opts)
      '';
      settings = {__raw = "require('opts.transparent').opts";};
    };
  };
}
