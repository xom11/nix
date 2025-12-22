#Requires AutoHotkey v2.0

#!p:: {
    fullPath := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk"
    Run 'explorer.exe "' . fullPath . '"'
}

#!o:: {
    fullPath := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk" ; <--- Thay đường dẫn máy bạn vào đây
    Run fullPath
}