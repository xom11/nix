{ ... }:

{
  programs = {
    nixvim = {
      plugins = {
        lsp.servers.nixd.enable = true;
        lsp.servers.cssls.enable = true;
        lsp.servers.jsonls.enable = true;
        lsp.servers.lua_ls.enable = true;
        lsp.servers.pylsp.enable = true;
        lsp.servers.yamlls.enable = true;
      };
    };
  };
}