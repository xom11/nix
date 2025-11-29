{
  config,
  ckModule,
  ...
}:
# Keymap Tab (cmp.nix)
ckModule config ./.
{
  programs.nixvim.plugins.leap = {
    enable = true;
    luaConfig.post = ''
      vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
      vim.keymap.set('n',             'S', '<Plug>(leap-from-window)')
    '';
  };
}
