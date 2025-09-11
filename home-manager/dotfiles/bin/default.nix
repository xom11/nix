{ lib, ... }:

let
  inherit (builtins) filter map toString;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasPrefix;

  # Lấy danh sách tất cả các tệp trong thư mục hiện tại.
  # Sử dụng `listFilesRecursive` để tìm các tệp. Dấu chấm (`.`) đại diện cho thư mục hiện tại.
  allFiles = listFilesRecursive ./.;

  # Lọc các tệp để chỉ lấy những tệp bạn muốn.
  # Chúng ta sẽ lọc những tệp có tên bắt đầu bằng `.x`.
  xorgFiles = filter (file: hasPrefix ".x" (baseNameOf (toString file))) allFiles;

  # Tạo một thuộc tính (`attribute set`) từ danh sách các tệp đã lọc.
  # Dùng `lib.attrsets.genAttrs` để tạo một tập hợp thuộc tính từ một danh sách.
  # Khóa (`name`) là tên của tệp và giá trị (`path`) là một đối tượng có thuộc tính `source` trỏ đến tệp đó.
  xorgHomeFiles = lib.attrsets.genAttrs xorgFiles (file: {
    source = file;
  });

in

{
  home.file = xorgHomeFiles;
}