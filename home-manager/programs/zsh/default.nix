{lib, config, pkgs, device, ... }:
let
  cfg = config.modules.programs.zsh;
in
{
  options.modules.programs.zsh = {
    enable = lib.mkEnableOption "Enable zsh as shell";
  };
  config = lib.mkIf cfg.enable
  {
    programs.zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      # historySubstringSearch.enable = true;
      history = {
        ignoreDups = true;
        ignoreAllDups = true;
        save = 1000000;
        size = 1000000;
      };
      oh-my-zsh = {
        enable = true;
        # theme = "robbyrussell";
        plugins = [
          "git"
          "extract"
          "copyfile"
          "copypath"
          "fzf"
          "z"
          "uv"
          # "tmux"
          "sudo"
        ];
      };
      plugins = [
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
        {
          name = "powerlevel10k";
          src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
          file = "powerlevel10k.zsh-theme";
        }
        {
          name = "p10k";
          src = ./zshrc;
          file = "p10k.zsh";
        }
        {
          name = "func";
          src = ./zshrc;
          file = "func.zsh";
        }
        {
          name = "py";
          src = ./zshrc;
          file = "py.zsh";
        }
        {
          name = "alias";
          src = ./zshrc;
          file = "alias.zsh";
        }
      ] ++ lib.optional (device != "server") 
        {
          name = "zsh-vi-mode";
          src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
        };
      dirHashes = {
        # cd ~cfg
        cfg = "$HOME/.config";
        nix = "$HOME/.nix";
        dev = "$HOME/Documents/dev";
        pass = "$HOME/.password-store";
        note = "$HOME/Documents/note";
        test = "$HOME/Documents/test";
      };

      sessionVariables = {

      };

      initContent = ''
        ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
        zvm_after_init() {
          source ${config.programs.fzf.package}/share/fzf/key-bindings.zsh
        }      

        printf '\e[5 q'

      '';
    }; 
  };
}
