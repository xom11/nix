#Requires AutoHotkey v2.0

#SingleInstance Force

; Thiết lập thư mục làm việc về chính thư mục chứa file main này
SetWorkingDir A_ScriptDir 

; --- IMPORT CÁC MODULE ---
#Include kanata.ahk

; Thông báo nhỏ khi nạp xong tất cả
TrayTip "Hệ thống AHK đã sẵn sàng!", "Startup", 1