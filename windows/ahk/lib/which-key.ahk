#Requires AutoHotkey v2.0

/**
 * Hàm tạo Menu phím tắt theo chuỗi (Giống RecursiveBinder)
 * @param title Tiêu đề của menu (ví dụ: "App Launcher")
 * @param items Map chứa danh sách phím và hành động
 */
WhichKey(title, items) {
    ; 1. TẠO GUI HIỂN THỊ
    myGui := Gui("+AlwaysOnTop -Caption +ToolWindow +Owner")
    myGui.SetFont("s12", "Segoe UI")
    myGui.BackColor := "1e1e1e" ; Màu nền tối (Dark mode)
    myGui.Color := "c5c5c5" ; Màu chữ
    
    ; Thêm tiêu đề
    myGui.SetFont("s14 w700 c61afef") ; Màu tím kiểu OneDark
    myGui.Add("Text", "Center w300", title)
    myGui.SetFont("s11 w400 cWhite")
    
    ; Tạo danh sách nhắc lệnh
    displayText := ""
    for key, val in items {
        ; key: phím tắt, val.Desc: mô tả
        displayText .= "[" . key . "]  " . val.Desc . "`n"
    }
    myGui.Add("Text", "Center w300", displayText)
    
    ; Hiện GUI ở giữa màn hình (hoặc góc dưới tùy bạn chỉnh)
    myGui.Show("NoActivate") 
    
    ; 2. LẮNG NGHE PHÍM BẤM TIẾP THEO
    ; L1: Chờ đúng 1 ký tự
    ; T3: Timeout 3 giây (không bấm gì tự tắt)
    ih := InputHook("L1 T3") 
    ih.Start()
    ih.Wait()
    
    ; 3. XỬ LÝ
    myGui.Destroy() ; Tắt menu ngay lập tức
    
    if (ih.Input = "") {
        return ; Hết giờ hoặc không bấm gì
    }
    
    ; Kiểm tra xem phím vừa bấm có trong danh sách không
    if items.Has(ih.Input) {
        ; Gọi hàm action đã định nghĩa
        items[ih.Input].Action()
    } else {
        ; (Tùy chọn) Báo lỗi nếu bấm sai
        ; SoundBeep 300, 150 
    }
}