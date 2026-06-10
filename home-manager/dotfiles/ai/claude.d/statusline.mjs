#!/usr/bin/env node
// Claude Code statusline — context window, 5h & weekly limits, git, cost.
// Reads the statusLine JSON on stdin, prints one ANSI-colored line.
// Docs: https://code.claude.com/docs/en/statusline.md

let raw = "";
process.stdin.on("data", (c) => (raw += c));
process.stdin.on("end", () => {
  let d = {};
  try {
    d = JSON.parse(raw);
  } catch {
    process.stdout.write("");
    return;
  }
  process.stdout.write(render(d));
});

// ── ANSI helpers ──────────────────────────────────────────────
const E = (n) => `\x1b[${n}m`;
const R = E(0);
const dim = (s) => E(2) + s + R;
const bold = (s) => E(1) + s + R;
const c = (code, s) => E(code) + s + R;
const SEP = dim(" │ ");

// color a value by how "full" a percentage is
const pctColor = (p) => (p >= 80 ? 31 : p >= 50 ? 33 : 32); // red / yellow / green

// compact token count: 1234 -> 1.2k, 16000 -> 16k
function tok(n) {
  if (n == null) return "?";
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(1).replace(/\.0$/, "") + "M";
  if (n >= 1000) return Math.round(n / 1000) + "k";
  return String(n);
}

// 10-cell progress bar
function bar(p, width = 10) {
  const filled = Math.max(0, Math.min(width, Math.round((p / 100) * width)));
  return "█".repeat(filled) + "░".repeat(width - filled);
}

// epoch seconds -> "2h14m" / "3d4h" / "<1m" countdown until reset
function until(epoch) {
  if (!epoch) return "";
  let s = epoch - Math.floor(Date.now() / 1000);
  if (s <= 0) return "now";
  const dd = Math.floor(s / 86400);
  s -= dd * 86400;
  const hh = Math.floor(s / 3600);
  s -= hh * 3600;
  const mm = Math.floor(s / 60);
  if (dd > 0) return `${dd}d${hh}h`;
  if (hh > 0) return `${hh}h${mm}m`;
  if (mm > 0) return `${mm}m`;
  return "<1m";
}

// home-relative, shortened cwd
function shortDir(p, home) {
  if (!p) return "?";
  if (home && p.startsWith(home)) p = "~" + p.slice(home.length);
  return p;
}

function render(d) {
  const parts = [];

  // ── model (+ effort / thinking) ──
  let model = d.model?.display_name || "?";
  if (d.effort?.level) model += dim("·") + d.effort.level;
  if (d.thinking?.enabled) model += " " + c(35, "✦");
  parts.push(c(36, " ") + bold(model)); //

  // ── dir + git branch ──
  const home = process.env.HOME;
  let loc = c(34, " ") + shortDir(d.workspace?.current_dir || d.cwd, home); //
  const branch = d.workspace?.git_worktree || d.worktree?.branch;
  if (branch) loc += "  " + c(35, " ") + branch; //
  parts.push(loc);

  // ── context window ──
  const cw = d.context_window;
  if (cw && cw.used_percentage != null) {
    const p = Math.round(cw.used_percentage);
    const used = (cw.total_input_tokens || 0) + (cw.total_output_tokens || 0);
    const size = cw.context_window_size || 200000;
    const seg =
      dim("ctx ") +
      c(pctColor(p), bar(p)) +
      ` ${c(pctColor(p), p + "%")} ` +
      dim(`${tok(used)}/${tok(size)}`);
    parts.push(seg);
  } else {
    parts.push(dim("ctx —"));
  }

  // ── rate limits (Claude.ai Pro/Max, after 1st API call) ──
  const rl = d.rate_limits;
  if (rl?.five_hour?.used_percentage != null) {
    const p = Math.round(rl.five_hour.used_percentage);
    const r = until(rl.five_hour.resets_at);
    parts.push(
      dim("5h ") +
        c(pctColor(p), bar(p, 4)) +
        ` ${c(pctColor(p), p + "%")}` +
        (r ? dim(" ↻" + r) : "")
    );
  }
  if (rl?.seven_day?.used_percentage != null) {
    const p = Math.round(rl.seven_day.used_percentage);
    const r = until(rl.seven_day.resets_at);
    parts.push(
      dim("wk ") +
        c(pctColor(p), bar(p, 4)) +
        ` ${c(pctColor(p), p + "%")}` +
        (r ? dim(" ↻" + r) : "")
    );
  }

  // ── cost + lines changed ──
  const cost = d.cost;
  if (cost) {
    const bits = [];
    if (cost.total_cost_usd != null) bits.push(c(32, "$" + cost.total_cost_usd.toFixed(3)));
    const add = cost.total_lines_added || 0;
    const del = cost.total_lines_removed || 0;
    if (add || del) bits.push(c(32, "+" + add) + dim("/") + c(31, "-" + del));
    if (bits.length) parts.push(bits.join(" "));
  }

  return " " + parts.join(SEP);
}
