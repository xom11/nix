{pkgs, ...}:
{
  programs.nixvim.plugins.treesitter = {
    enable = true;
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      bash
      json
      lua
      markdown
      nix
      toml
      yaml
      python
    ];
    settings = {
      auto_install = true;
      highlight.enable = true;
      indent.enable = true;
    };
  };
}
