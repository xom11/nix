{ ... }:

{
  programs.nixvim.plugins ={
    lsp ={
      enable = true;
      servers = {
        pylsp.enable = true;
        nixd.enable = true;
        lua_ls.enable = true;
        jsonls.enable = true;
        yamlls.enable = true;
      };
    };
  };
}