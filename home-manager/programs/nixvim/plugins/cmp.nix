{
  config,
  ckModule,
  ...
}:
ckModule config ./..
{
  programs.nixvim.plugins = {
    cmp-nvim-lsp = {
      enable = true;
    };
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {__raw = "require('opts.cmp').opts";};
      cmdline = {
        ":" = {
          mapping = {
            __raw = "require('opts.cmp').cmdline[':'].mapping";
          };
          sources = [
            { name = "path"; }
            { name = "cmdline"; }
          ];
        };
      };
    };
  };
}
