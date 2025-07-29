{ config, pkgs, ... }:

{
  programs.zathura = {
    enable = true; 
    extraPackages = with pkgs; [
      zathura-pdf-mupdf
      zathura-djvu   # Hỗ trợ file DjVu
      zathura-ps     # Hỗ trợ file PostScript
      zathura-cb     # Hỗ trợ định dạng truyện tranh (CBR, CBZ)
      zathura-epub   # Hỗ trợ định dạng EPUB (nếu có)
    ];
}