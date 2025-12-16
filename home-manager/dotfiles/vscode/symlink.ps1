# 1. Xác định thư mục chứa file gốc (nơi bạn lưu script này)
$DotfilesDir = $PSScriptRoot

# 2. Xác định thư mục cấu hình của VS Code trên Windows
$VSCodeUserDir = "$env:APPDATA\Code\User"

# Danh sách các file cần tạo link
$Files = @("settings.json", "keybindings.json")

foreach ($FileName in $Files) {
    $SourceFile = Join-Path $DotfilesDir $FileName
    $SymlinkPath = Join-Path $VSCodeUserDir $FileName

    # Kiểm tra xem file gốc có tồn tại không trước khi tạo link
    if (Test-Path $SourceFile) {
        # Nếu đã có file hoặc link cũ ở đích, xóa nó đi để tránh lỗi
        if (Test-Path $SymlinkPath) {
            Write-Host "Đang xóa file cũ tại: $SymlinkPath" -ForegroundColor Yellow
            Remove-Item $SymlinkPath -Force
        }

        # Tạo Symbolic Link
        New-Item -ItemType SymbolicLink -Path $SymlinkPath -Target $SourceFile
        Write-Host "Đã tạo Symlink thành công cho: $FileName" -ForegroundColor Green
    } else {
        Write-Warning "Không tìm thấy file gốc: $SourceFile. Bỏ qua..."
    }
}