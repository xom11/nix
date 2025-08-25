{ pkgs, ... }:

{
  programs.nixvim.plugins ={
    lsp = {
      enable = true;
      servers = {
        pyright = {
          enable = true;
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "off";
                autoSearchPaths = true;
                useLibraryCodeForTypes = true;
              };
            };
          };
        };
        nixd.enable = true;
        lua_ls.enable = true;
        jsonls.enable = true;
        yamlls.enable = true;
        marksman.enable = true;
      };
    };
    lsp-format = {
      enable = true;
    };
  };
}
