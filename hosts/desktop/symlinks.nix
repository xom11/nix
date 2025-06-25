{ config, lib, pkgs, ... }: # Đảm bảo các tham số đầu vào cần thiết

let
  # Hàm này sẽ tạo symlinks cho tất cả các file trong sourceDir và các thư mục con của nó.
  # Nó sẽ giữ nguyên cấu trúc thư mục từ sourceDir bên trong targetBase.
  createSymlinksForDirectory = targetBase: sourceDir:
    let
      # Sử dụng lib.filesystem.listFilesRecursive để lấy tất cả các file (đường dẫn tuyệt đối)
      # trong sourceDir và các thư mục con của nó.
      # Đảm bảo sourceDir là một đường dẫn tuyệt đối hoặc được định nghĩa tốt để lib.filesystem.listFilesRecursive hoạt động.
      # Nếu sourceDir là một đường dẫn tương đối như ./local/share, Nix sẽ tự động biến nó thành đường dẫn tuyệt đối trong sandbox build.
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
  # home.file mong đợi một attribute set, nơi các khóa là đường dẫn đích và giá trị là các tùy chọn file.
  # createSymlinksForDirectory trả về một attribute set như vậy,
  # nên bạn có thể sử dụng nó trực tiếp hoặc hợp nhất nhiều tập hợp nếu cần.
  home.file = lib.mkMerge [
    # Ví dụ sử dụng:
    # tạo symlink cho các file từ ./local/share vào ~/.nix-profile/share
    (createSymlinksForDirectory ".nix-profile/share" ./local/share)
  ];
}