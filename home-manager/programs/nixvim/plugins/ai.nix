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
        settings = {
          provider = "gemini";
          providers = {
            gemini = {
              model = "gemini-2.5-flash";
              api_key_name = "GEMINI_KEY";
            };
          };
        };
      };
      # PART: codecompanion.nvim
      codecompanion = {
        enable = false;
      };
    };
  };
}
