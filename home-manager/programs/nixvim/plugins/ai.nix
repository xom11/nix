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
        settings = {
          panel = {
            enabled = true;
            auto_refresh = true;
          };
          suggestion = {
            enabled = true;
            auto_trigger = true;
            debounce = 75;
            keymap = {
              accept = "<M-l>";
              accept_word = "<M-k>";
              dismiss = "<C-]>";
            };
          };
        };
        luaConfig.post = ''
          highlight = {
            CopilotSuggestion = {
              italic = true,
              fg = "#555555",
            },
          }
        '';
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
