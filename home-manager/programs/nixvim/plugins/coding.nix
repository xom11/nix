{
  config,
  ckModule,
  pkgs,
  ...
}:
ckModule config ./..
{
  # PART: telescope
  programs.nixvim.telescope = {
    enable = true;
    settings = {__raw = "require('opts.telescope')";};
    extensions = {
      ui-select.enable = true;
      frecency = {
        enable = true;
        # Fix issue https://github.com/nvim-telescope/telescope-frecency.nvim/issues/270
        settings.db_safe_mode = false;
        # Fix issue https://github.com/nvim-telescope/telescope-frecency.nvim/issues/105
        settings.db_validate_threshold = 1;
      };
      fzf-native.enable = true;
      file-browser = {
        enable = true;
        settings.hidden = true;
        settings.depth = 9999999999;
        settings.auto_depth = true;
      };
    };
  };
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    settings = {__raw = "require('opts.conform')";};
  };
  home.packages = with pkgs; [
    black
    shfmt
    stylua
    alejandra
    prettierd
    yamllint
    yamlfmt
    taplo
  ];
}
