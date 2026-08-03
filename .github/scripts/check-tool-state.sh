#!/usr/bin/env bash
#
# Giữ trạng thái cục bộ của công cụ AI/dev ra khỏi repo public.
#
# Kiểm hai điều, và điều thứ hai mới là lý do file này tồn tại:
#
#   1. Không file nào dưới các thư mục đó đang được git theo dõi.
#   2. .gitignore THỰC SỰ khớp với chúng.
#
# Chỉ kiểm (1) thì không đủ. Một dòng .gitignore gõ sai chính tả vẫn nằm đó, vẫn
# trông như đang bảo vệ, nhưng không khớp gì cả — và git không có cách nào báo
# cho bạn biết. Repo sạch hôm nay chỉ vì tình cờ chưa ai tạo file ở đúng chỗ đó.
#
# Đây không phải giả thuyết: dòng `.anitigravitycli/` (thừa một chữ `i`) đã nằm
# trong .gitignore của repo này một thời gian dài, và `.antigravitycli/` bị đẩy
# lên public suốt thời gian đó. Kiểm (2) bắt được ngay cả khi chưa có gì bị
# commit, tức là bắt trước khi thiệt hại xảy ra.
#
# Chạy tay:  ./.github/scripts/check-tool-state.sh

set -uo pipefail

DIRS=(
    .claude
    .antigravitycli
    .codegraph
    .gemini
    .gstack
    .superpowers
    docs/superpowers
)

fail=0

for d in "${DIRS[@]}"; do
    tracked=$(git ls-files -- "$d")
    if [ -n "$tracked" ]; then
        fail=1
        echo "::error::'$d' dang duoc git theo doi. Go bang: git rm -r --cached '$d'"
        echo "$tracked" | head -5 | sed 's/^/    /'
        n=$(echo "$tracked" | wc -l | tr -d ' ')
        if [ "$n" -gt 5 ]; then echo "    ... va $((n - 5)) file nua"; fi
    fi

    # Hỏi bằng một đường dẫn con thay vì hỏi thẳng thư mục: luật dạng `dir/` chỉ
    # khớp thư mục, và cách này đúng kể cả khi thư mục chưa tồn tại trên đĩa --
    # trên runner CI vừa checkout thì phần lớn chúng không có.
    if ! git check-ignore -q "$d/.probe"; then
        fail=1
        echo "::error::'$d' KHONG duoc .gitignore khop -- kiem lai chinh ta trong .gitignore"
    fi
done

if [ "$fail" -eq 0 ]; then
    echo "OK: ${#DIRS[@]} thu muc trang thai cong cu, deu bi ignore va deu khong tracked."
fi

exit "$fail"
