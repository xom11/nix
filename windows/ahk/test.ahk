; Nhấn Ctrl + F12 để bật/tắt chế độ No Decoration cho cửa sổ đang chọn
^F12:: {
    targetWin := WinExist("A")
    if !targetWin
        return

    ; Lấy style hiện tại của cửa sổ
    currentStyle := WinGetStyle(targetWin)

    ; Kiểm tra xem có thanh tiêu đề (WS_CAPTION = 0xC00000) không
    if (currentStyle & 0xC00000) {
        ; Xóa thanh tiêu đề và viền dày (WS_THICKFRAME = 0x40000)
        WinSetStyle("-0xC40000", targetWin)
    } else {
        ; Khôi phục lại style mặc định
        WinSetStyle("+0xC40000", targetWin)
    }
}