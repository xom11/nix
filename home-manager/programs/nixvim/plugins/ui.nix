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
    };
    render-markdown.enable = true;
    dashboard.enable = true;
    colorizer.enable = true;
    noice.enable = true;
    image.enable = true;
    barbecue.enable = true;
    notify = {
      enable = true;
      settings = {
        background_colour = "#000000";
        top_down = false;
      };
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
