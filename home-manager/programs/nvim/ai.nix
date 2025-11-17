{ lib, config, ... }:
# Keymap Tab (cmp.nix)
let
  cfg = config.modules.programs.nvim;
in
lib.mkIf cfg.enable
{
  programs.nixvim = {
    # Copilot-lua Configuration   
    plugins = {
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
      };
    };
    highlight = {
      CopilotSuggestion = {
        italic = true;
        fg = "#555555";
      };
    };

    # Avante Configuration
    plugins.avante = {
      enable = true;
      settings = {
        provider = "copilot";
        acp_providers = ''{
          ["gemini-cli"] = {
            command = "gemini",
            args = { "--experimental-acp" },
            env = {
              NODE_NO_WARNINGS = "1",
              GEMINI_API_KEY = os.getenv("GEMINI_API_KEY"),
            },
          },
        '';
      };
    };
  };
}
