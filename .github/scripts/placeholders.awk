# Moi truong credential trong dotfiles phai la cho de trong, khong duoc la gia tri that.
#
# Luat di NGUOC chieu may quet thong thuong: khong di tim "cai gi trong giong
# key", ma liet ke nhung hinh dang gia tri DUOC PHEP. Mot dang key moi la van bi
# bat, vi cau hoi la "gia tri nay co phai placeholder khong" chu khong phai "gia
# tri nay co giong key khong". Do la cho may quet theo mau thua: gitleaks da bo
# sot dung key that o repo nay.
#
# Chi xet STRING LITERAL. `Authorization: AUTH_TOKEN` la bieu thuc trong ma, tham
# chieu toi cho khac, khong phai cho chua duoc secret. `"maxTokens": 16384` cung
# vay. Bo qua chung loai duoc gan het bao gia ma khong mat gi.
#
# POSIX awk thuan: mawk tren runner Ubuntu khong co match() ba tham so cua gawk,
# nen cho nao can "capture group" deu tach tay bang substr().

BEGIN {
    nbad = 0

    # So voi tolower(key), nen viet thuong het.
    cred = "apikey|api_key|api-key|authorization|auth_?token|access_?token" \
        "|refresh_?token|token|secret|password|passwd|passphrase" \
        "|credential|client_?secret|private_?key|bearer"

    ok = "\\$\\{?[A-Za-z_]" \
        "|\\{env:[A-Za-z_]" \
        "|\\$env:[A-Za-z_]" \
        "|process\\.env\\." \
        "|os\\.environ" \
        "|Deno\\.env" \
        "|getenv" \
        "|ENV\\["

    okword = "^(your_|change_?me|placeholder|example|sample|dummy|todo|xxx|\\.\\.\\.|<)"

    SQ = "'"
    BQ = "`"
}

{
    line = $0
    n = length(line)

    for (i = 1; i <= n; i++) {
        c = substr(line, i, 1)
        if (c != ":" && c != "=") continue

        # ---- ben trai dau phan cach: ten truong ----
        left = substr(line, 1, i - 1)
        sub(/[ \t]+$/, "", left)
        last = substr(left, length(left), 1)
        if (last == "\"" || last == SQ || last == BQ)
            left = substr(left, 1, length(left) - 1)

        key = ""
        for (j = length(left); j >= 1; j--) {
            ch = substr(left, j, 1)
            if (ch ~ /[A-Za-z0-9_.-]/) key = ch key
            else break
        }
        if (key == "") continue
        if (tolower(key) !~ cred) continue

        # ---- ben phai: chi quan tam string literal ----
        right = substr(line, i + 1)
        sub(/^[ \t]+/, "", right)

        q = substr(right, 1, 1)
        if (q != "\"" && q != SQ && q != BQ) continue

        end = index(substr(right, 2), q)
        if (end == 0) continue
        v = substr(right, 2, end - 1)

        if (v == "") continue
        if (v ~ ok) continue
        if (tolower(v) ~ okword) continue

        nbad++
        # In TEN truong va so dong, khong in gia tri. Cung ly do nhu hook pre-push:
        # thong bao khong duoc tu no tro thanh mot lan ro ri nua.
        if (ci)
            printf "::error file=%s,line=%d::truong '%s' la literal, phai la placeholder\n", FILENAME, FNR, key
        printf "  %s:%d  truong '%s' la literal\n", FILENAME, FNR, key
    }
}

END { exit(nbad > 0 ? 1 : 0) }
