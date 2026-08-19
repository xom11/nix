#!/usr/bin/env python3
"""Dan ten phien Claude Code len pane Herdr tuong ung.

Sidebar cua Herdr in ra *loai* agent ("claude"), giong het nhau o moi pane, nen
nhin vao do khong biet phien nao ten gi. Cai ten that su dung de goi mot phien --
ten ma ListAgents in ra va SendMessage nhan -- nam trong
~/.claude/sessions/<pid>.json duoi khoa "name".

Script noi hai ben lai bang sessionId (Herdr giu no o agent_session.value), roi:

  * pane report-metadata --token session=<ten>  -> token $session cho sidebar,
    config.toml dung no o hang tren cua moi agent (ui.sidebar.agents.rows_by_agent)

Hang duoi cua sidebar co y de nguyen token `agent` ("claude"). Do la ly do script
KHONG dat display_agent va KHONG goi `agent rename`: ca hai deu chay vao token
`agent`, lam hang duoi lap lai y het hang tren. Ban nao lo dat roi thi xoa di.
Muon goi mot pane tu CLI thi dung pane_id (`herdr agent get wN:p6`).

Chay bao nhieu lan cung duoc, khong doi gi thi khong goi gi. Vua la hook
SessionStart, vua chay tay duoc de quet lai moi pane dang song.

PANE CUA CHINH PHIEN NAY KHONG DUOC LAY QUA `agent list`. Herdr chi biet
sessionId cua mot pane khi ~/.claude/hooks/herdr-agent-state.sh goi
pane.report_agent_session -- ma do CUNG la mot hook SessionStart, chay song
song voi file nay. Ta thuong thang cuoc dua do (day chi la python3 roi
`herdr agent list`; ben kia la sh -> mktemp -> cat -> python3 -> socket), va
khi thang thi luc doc bang, pane cua chinh minh CHUA CO TRONG DO nen vong lap
khong bao gio cham toi no. Do 19/08/2026: 5/7 phien mo moi bi trong hang tren;
phan con lai xanh, tuc day la CUOC DUA chu khong phai thu tu co dinh -- dung
ket luan "khong tai hien duoc" tu mot lan chay. Ten phien thi luon san sang,
nua Claude Code khong dinh gi. Trieu chung: phien vua mo trong hang tren, roi
tu nhien co ten khi mot phien khac mo sau do quet lai.
Nen pane cua minh lay thang tu $HERDR_PANE_ID + session_id trong payload cua
hook, khong hoi herdr. Vong quet `agent list` giu nguyen, no lo cho pane cu.

Tu ban thu cong:  ~/.claude/hooks/herdr-peer-name.py
"""

import json
import os
import subprocess
import sys

SOURCE = "claude-peer-name"


def herdr(*args):
    """Goi CLI herdr, tra ve JSON da parse hoac None. Khong bao gio nem loi."""
    try:
        out = subprocess.run(
            ("herdr",) + args,
            capture_output=True,
            text=True,
            timeout=5,
        )
    except Exception:
        return None
    if out.returncode != 0:
        return None
    try:
        return json.loads(out.stdout)
    except Exception:
        return None


def live_sessions():
    """sessionId -> ten phien, chi lay nhung phien co tien trinh con song."""
    names = {}
    root = os.path.expanduser("~/.claude/sessions")
    try:
        entries = os.listdir(root)
    except OSError:
        return names
    for entry in entries:
        if not entry.endswith(".json"):
            continue
        try:
            with open(os.path.join(root, entry), encoding="utf-8") as handle:
                data = json.load(handle)
        except Exception:
            continue
        sid = data.get("sessionId")
        name = data.get("name")
        pid = data.get("pid")
        if not (isinstance(sid, str) and isinstance(name, str) and name):
            continue
        # File cua phien da chet van nam lai; ten cua no khong con goi duoc nua.
        if isinstance(pid, int):
            try:
                os.kill(pid, 0)
            except OSError:
                continue
        names[sid] = name
    return names


def report(pane, name):
    herdr(
        "pane",
        "report-metadata",
        pane,
        "--source",
        SOURCE,
        "--token",
        f"session={name}",
        "--clear-display-agent",
    )


def main():
    # Hook nhan JSON qua stdin. Payload mang session_id cua chinh phien nay --
    # thu duy nhat noi duoc pane cua minh voi ten khi herdr chua biet gi ve no.
    payload = ""
    if not sys.stdin.isatty():
        try:
            payload = sys.stdin.read()
        except Exception:
            pass
    try:
        hook_input = json.loads(payload)
    except Exception:
        hook_input = {}

    if os.environ.get("HERDR_ENV") != "1":
        return 0

    names = live_sessions()
    if not names:
        return 0

    labelled = set()

    # Pane cua chinh phien nay -- xem doan PANE CUA CHINH PHIEN NAY o dau file.
    own_pane = os.environ.get("HERDR_PANE_ID")
    own_sid = hook_input.get("session_id")
    own_name = names.get(own_sid) if isinstance(own_sid, str) else None
    if own_pane and own_name:
        report(own_pane, own_name)
        labelled.add(own_pane)

    # Cac pane con lai: quet nhu cu, vua dan cho phien cu vua tu chua neu lan
    # truoc truot. Chay tay (khong co payload) thi day la duong duy nhat.
    listing = herdr("agent", "list")
    agents = (listing or {}).get("result", {}).get("agents", [])

    for agent in agents:
        pane = agent.get("pane_id")
        sid = (agent.get("agent_session") or {}).get("value")
        name = names.get(sid)
        if not (pane and name) or pane in labelled:
            continue

        # Ten agent do lan chay truoc dat se de len token `agent` cua hang duoi.
        if agent.get("name"):
            herdr("agent", "rename", pane, "--clear")

        report(pane, name)

    return 0


if __name__ == "__main__":
    sys.exit(main())
