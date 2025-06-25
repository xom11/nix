{pkgs, lib, ... }:

let
  # Hàm này sẽ tạo symlinks cho tất cả các file trong sourceDir và các thư mục con của nó.
  # Nó sẽ giữ nguyên cấu trúc thư mục từ sourceDir bên trong targetBase.
  createSymlinksForDirectory = targetBase: sourceDir:
    let
      # Sử dụng lib.filesystem.listFilesRecursive để lấy tất cả các file (đường dẫn tuyệt đối)
      # trong sourceDir và các thư mục con của nó.
      allFiles = lib.filesystem.listFilesRecursive sourceDir;

      # Ánh xạ từng đường dẫn file để tạo cấu trúc symlink.
      symlinks = lib.mapAttrs'
        (index: filePath: # filePath ở đây là đường dẫn tuyệt đối đến file
          let
            # Tính toán đường dẫn tương đối của file so với sourceDir.
            # Ví dụ: nếu sourceDir là /home/user/dotfiles và filePath là /home/user/dotfiles/config/nvim/init.vim
            # thì relativePath sẽ là config/nvim/init.vim
            relativePath = lib.removePrefix "${sourceDir}/" filePath;
          in
          {
            # Tên symlink sẽ là targetBase + đường dẫn tương đối của file.
            # Ví dụ: nếu targetBase là ~/.config và relativePath là config/nvim/init.vim
            # thì tên symlink sẽ là ~/.config/config/nvim/init.vim
            name = "${targetBase}/${relativePath}";
            value = {
              source = filePath; # Nguồn của symlink là đường dẫn tuyệt đối đến file gốc
              enable = true;
            };
          })
        allFiles;
    in
    symlinks;

in
{
    home.file = lib.mkMerge [
    (createSymlinksForDirectory ".nix-profile/share" ./local/share)
  ];
}

# Ví dụ về cách sử dụng hàm:
# Giả sử bạn có một thư mục dotfiles với cấu trúc như sau:
# /home/user/dotfiles/
# ├── .bashrc
# ├── .config/
# │   └── nvim/
# │       └── init.vim
# └── .zshrc
#
# Để tạo symlink cho tất cả các file này vào thư mục home của bạn (~), bạn có thể gọi:
#
# let
#   myDotfiles = createSymlinksForDirectory
#     "/home/user" # targetBase: thư mục đích cho các symlink
#     "/home/user/dotfiles"; # sourceDir: thư mục chứa các file nguồn
# in
# myDotfiles
#
# Kết quả sẽ là một tập hợp các symlink có cấu trúc tương tự:
# {
#   "/home/user/.bashrc" = { source = "/home/user/dotfiles/.bashrc"; enable = true; };
#   "/home/user/.config/nvim/init.vim" = { source = "/home/user/dotfiles/.config/nvim/init.vim"; enable = true; };
#   "/home/user/.zshrc" = { source = "/home/user/dotfiles/.zshrc"; enable = true; };
# }