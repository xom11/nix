{
  lib,
  config,
  pkgs,
  device,
  ...
}: let
  cfg = config.modules.programs.zsh;
in {
  options.modules.programs.zsh = {
    enable = lib.mkEnableOption "Enable zsh as shell";
  };
  config =
    lib.mkIf cfg.enable
    {
      programs.zsh = {
        enable = true;
        dotDir = "${config.xdg.configHome}/zsh";
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        # historySubstringSearch.enable = true;
        history = {
          path = "${config.xdg.configHome}/zsh/.zsh_history";
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
            "rust"
          ];
        };
        plugins =
          [
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
            {
              name = "other";
              src = ./zshrc;
              file = "other.zsh";
            }
          ]
          ++ lib.optional (device != "server")
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

            # fix Alt + key not working
            bindkey '\e[1;3D' backward-word
            bindkey '\e[1;3C' forward-word
            bindkey '\e\x7f' backward-kill-word

            # fix other in https://github.com/jeffreytse/zsh-vi-mode/issues/288
            bindkey '^[' zvm_readkeys_handler
            bindkey '^[^[' sudo-command-line
            bindkey '^[OA' up-line-or-beginning-search
            bindkey '^[OB' down-line-or-beginning-search
            bindkey '^[OC' vi-forward-char
            bindkey '^[OD' vi-backward-char
            bindkey '^[OF' end-of-line
            bindkey '^[OH' beginning-of-line
            bindkey '^[[1;5C' forward-word
            bindkey '^[[1;5D' backward-word
            bindkey '^[[200~' bracketed-paste
            bindkey '^[[3;5~' kill-word
            bindkey '^[[3~' delete-char
            bindkey '^[[5~' up-line-or-history
            bindkey '^[[6~' down-line-or-history
            bindkey '^[[A' up-line-or-beginning-search
            bindkey '^[[B' down-line-or-beginning-search
            bindkey '^[[C' vi-forward-char
            bindkey '^[[D' vi-backward-char
            bindkey '^[[F' end-of-line
            bindkey '^[[H' beginning-of-line
            bindkey '^[[Z' reverse-menu-complete
            bindkey '^[c' fzf-cd-widget
          }

        '';
      };
    };
}
