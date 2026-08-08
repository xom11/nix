#Requires AutoHotkey v2.0

; Ban song sinh cua configs/shortcuts/parse.lua. CI so dump cua ca hai voi
; apps.expected.tsv -- lech la do.
;
; Chi hieu subset TOML: dong trong | # | [[app]] | [[shift]] | khoa = "gia tri".
; Thu khac thi throw, KHONG bo qua.

ShortcutsDir() => RegExReplace(A_LineFile, "[^\\]+$", "")

ShortcutsParse(path) {
    static FIELD := Map("key",1, "id",1, "gnome",1, "macos",1, "sway",1, "windows",1)

    layers := Map("app", [], "shift", [])
    entry := ""
    lineNo := 0

    prevEnc := A_FileEncoding
    FileEncoding("UTF-8")
    try {
        Loop Read path {
            lineNo++
            s := Trim(A_LoopReadLine, " `t`r")

            if (s = "" || SubStr(s, 1, 1) = "#")
                continue

            if (s = "[[app]]" || s = "[[shift]]") {
                entry := Map()
                layers[SubStr(s, 3, StrLen(s) - 4)].Push(entry)
                continue
            }

            if !RegExMatch(s, '^([a-z_]+)\s*=\s*"([^"]*)"$', &m)
                throw Error("dong " lineNo ": ngoai subset TOML cho phep: " s)
            if (entry = "")
                throw Error("dong " lineNo ": " m[1] " nam ngoai moi [[app]]/[[shift]]")
            if !FIELD.Has(m[1])
                throw Error("dong " lineNo ": khoa la " m[1])
            if entry.Has(m[1])
                throw Error("dong " lineNo ": " m[1] " lap trong cung mot bang")

            entry[m[1]] := m[2]
        }
    } finally {
        FileEncoding(prevEnc)
    }

    for layer in ["app", "shift"] {
        seen := Map()
        for e in layers[layer] {
            if !e.Has("key")
                throw Error("[[" layer "]]: thieu key")
            if !e.Has("id")
                throw Error("[[" layer "]] key=" e["key"] ": thieu id")
            if seen.Has(e["key"])
                throw Error("[[" layer "]]: phim " e["key"] " bi bind hai lan")
            seen[e["key"]] := 1
        }
    }

    return layers
}

ShortcutsIdFor(entry, target) => entry.Has(target) ? entry[target] : entry["id"]

ShortcutsBindings(layers, layer, target) {
    out := []
    for e in layers[layer] {
        id := ShortcutsIdFor(e, target)
        if (id != "")
            out.Push(Map("key", e["key"], "id", id))
    }

    ; Sap chen theo key. AHK v2.0 khong co Array.Sort, va mang o day chi vai
    ; chuc phan tu nen khong can gi hon.
    loop out.Length - 1 {
        i := A_Index + 1
        cur := out[i]
        j := i - 1
        while (j >= 1 && StrCompare(out[j]["key"], cur["key"], true) > 0) {
            out[j + 1] := out[j]
            j--
        }
        out[j + 1] := cur
    }
    return out
}

ShortcutsDump(layers, target) {
    lines := []
    for layer in ["app", "shift"] {
        for b in ShortcutsBindings(layers, layer, target)
            lines.Push(target "`t" layer "`t" b["key"] "`t" b["id"])
    }

    ; Sap CA DONG hoan chinh, giong parse.lua va dump.nix.
    loop lines.Length - 1 {
        i := A_Index + 1
        cur := lines[i]
        j := i - 1
        while (j >= 1 && StrCompare(lines[j], cur, true) > 0) {
            lines[j + 1] := lines[j]
            j--
        }
        lines[j + 1] := cur
    }

    out := ""
    for l in lines
        out .= l "`n"
    return out
}

; Che do dong lenh. Chi chay khi file NAY la script duoc goi, khong chay khi
; launch-app.ahk #Include no.
if (A_LineFile = A_ScriptFullPath) {
    if (A_Args.Length < 2 || A_Args[1] != "--dump") {
        FileAppend("dung: parse.ahk --dump <gnome|macos|sway|windows>`n", "**")
        ExitApp(2)
    }
    try {
        layers := ShortcutsParse(ShortcutsDir() "apps.toml")
    } catch as e {
        FileAppend("apps.toml: " e.Message "`n", "**")
        ExitApp(1)
    }
    ; UTF-8-RAW: khong BOM, khong doi line ending. Mac du moi id hien tai deu
    ; la ASCII, de mac dinh thi ma hoa phu thuoc locale cua may chay CI.
    FileAppend(ShortcutsDump(layers, A_Args[2]), "*", "UTF-8-RAW")
    ExitApp(0)
}
