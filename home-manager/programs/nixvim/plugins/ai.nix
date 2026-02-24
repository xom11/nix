{
  config,
  ckModule,
  ...
}:
# Keymap Tab (cmp.nix)
ckModule config ./..
{
  programs.nixvim = {
    plugins = {
      # PART: copilot-lua.nvim
      copilot-lua = {
        enable = true;
        settings = {__raw = "require('opts.copilot-lua')";};
      };
      # PART: avante.nvim
      avante = {
        enable = true;
        settings = {__raw = "require('opts.avante').opts";};
      };
      # PART: codecompanion.nvim
      codecompanion = {
        enable = false;
      };
    };
  };
}
