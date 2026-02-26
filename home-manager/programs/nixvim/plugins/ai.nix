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
      # PART: copilot
      copilot-lua = {
        enable = true;
        settings = {__raw = "require('opts.copilot-lua').opts";};
      };
      copilot-chat = {
        enable = true;
        settings = {__raw = "require('opts.copilot-chat').opts";};
      };
      # PART: avante.nvim
      avante = {
        enable = true;
        settings = {__raw = "require('opts.avante').opts";};
      };
      # PART: codecompanion.nvim
      # codecompanion = {
      #   enable = true;
      # };
    };
  };
}
