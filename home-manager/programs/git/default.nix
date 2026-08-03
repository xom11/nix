{
  config,
  lib,
  mkModule,
  pkgs,
  getPath,
  repoPath,
  ...
}: let
  pwd = getPath ./.;
  lazygitConfigDir =
    if pkgs.stdenv.isDarwin
    then "Library/Application Support/lazygit"
    else ".config/lazygit";
in
  mkModule config ./. {
    home.file = {
      ".config/git/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/git.d/config";
      };
      ".config/gh-dash/config.yml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/gh-dash.d/config.yml";
      };
      "${lazygitConfigDir}/config.yml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/lazygit.d/config.yml";
      };
    };
    home.packages = with pkgs; [
      git
      gh-dash
      delta
      lazygit
      diffnav
      gitleaks
    ];

    # Dựng hàng rào pre-push (xem .githooks/pre-push) trên mọi máy chạy switch.
    #
    # Đường dẫn phải TUYỆT ĐỐI. Git giải nghĩa `core.hooksPath` tương đối theo CWD
    # chứ không theo gốc repo, nên `.githooks` sẽ không tìm thấy khi `git push`
    # chạy từ một thư mục con -- và trượt kiểu đó thì im lặng, git không báo là
    # nó vừa bỏ qua hook.
    #
    # Gắn vào activation chứ không phải một câu hướng dẫn trong CLAUDE.md: repo
    # này đã có tiền lệ hàng rào "có mà không chắn", và thứ nào phải nhớ chạy tay
    # sau mỗi lần clone thì sớm muộn cũng có máy quên.
    home.activation.gitHooksPath = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -d "${repoPath}/.git" ] && [ -x "${repoPath}/.githooks/pre-push" ]; then
        ${pkgs.git}/bin/git -C "${repoPath}" config core.hooksPath "${repoPath}/.githooks"
      fi
    '';
  }
