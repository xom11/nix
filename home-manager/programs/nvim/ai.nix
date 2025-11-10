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
    plugins.avante = {
      enable = true;
    };
  };
}
