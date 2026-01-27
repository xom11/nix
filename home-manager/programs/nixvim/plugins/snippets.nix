{
  config,
  ckModule,
  ...
}:
ckModule config ./..
{
  programs.nixvim = {
    plugins = {
      luasnip = {
        enable = true;
      };
      frindle = {
        enable = true;
      };
    };
  };
}
