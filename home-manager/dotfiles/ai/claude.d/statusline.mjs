#!/usr/bin/env node
// Claude Code statusline — session, model, git, context window, token io, usage limits.
// Reads the statusLine JSON on stdin, prints one ANSI-colored line.
// Docs: https://code.claude.com/docs/en/statusline.md
//
// Glyphs are restricted to Box Drawing / Block Elements / Arrows so the line
// renders identically under DejaVuSansMono (kitty) and JetBrainsMono (alacritty)
// without depending on a Nerd Font patch.
//
// Layout is width-aware: Claude Code injects a live COLUMNS into this process
// (the tty itself is not reachable — all three fds are pipes and /dev/tty gives
// ENXIO). Segments degrade through three detail levels, then drop by priority.

import { execFileSync } from "node:child_process";

let raw = "";
process.stdin.on("data", (c) => (raw += c));
process.stdin.on("end", () => {
  let d;
  try {
    d = JSON.parse(raw);
  } catch {
    process.stdout.write("");
    return;
  }
  try {
    process.stdout.write(render(d));
  } catch {
    process.stdout.write("");
  }
});

// ── palette (256-color, tuned for a dark background) ──────────
const CLR = {
  sep: 238, // segment divider
  track: 240, // unfilled gauge / "no data"
  dim: 243, // secondary text
  label: 245, // segment labels: ctx, io, 5h, wk
  model: 111, // steel blue
  fast: 215, // fast mode
  think: 141, // extended thinking
  agent: 109,
  branch: 175, // dusty rose
  tree: 109, // worktree
  tokIn: 109, // cool: tokens going in
  tokOut: 180, // warm: tokens coming out
  ok: 114, // gauge: calm
  warn: 180, // gauge: watch
  hot: 173, // gauge: crowded
  crit: 167, // gauge: near the ceiling
};

const PR_CLR = {
  approved: CLR.ok,
  pending: CLR.warn,
  changes_requested: CLR.crit,
  draft: CLR.dim,
};

// ── ANSI helpers ──────────────────────────────────────────────
const RST = "\x1b[0m";
const sgr = (codes, s) => `\x1b[${codes}m${s}${RST}`;
const fg = (n, s) => sgr(`38;5;${n}`, s);
const bold = (n, s) => sgr(`1;38;5;${n}`, s);
const dim = (s) => fg(CLR.dim, s);
const SEP = fg(CLR.sep, " │ ");
const DOT = fg(CLR.sep, " · ");

const ANSI = /\x1b\[[0-9;]*m/g;
const vwidth = (s) => [...s.replace(ANSI, "")].length;
const clip = (s, n) => ([...s].length <= n ? s : [...s].slice(0, n - 1).join("") + "…");

// Terminal width. Absent COLUMNS means an unknown (likely non-interactive)
// consumer — assume roomy rather than truncating something nobody asked to trim.
const COLS = (() => {
  const n = Number.parseInt(process.env.COLUMNS ?? "", 10);
  return Number.isFinite(n) && n >= 20 ? n : 200;
})();

// gauge color: calm → watch → crowded → near the ceiling
const heat = (p) => (p >= 85 ? CLR.crit : p >= 70 ? CLR.hot : p >= 50 ? CLR.warn : CLR.ok);

// right-aligned so the line does not jitter as a value crosses 10% / 100%
const pct = (p) => fg(heat(p), String(p).padStart(3) + "%");

// compact token count: 1234 -> 1.2k, 16000 -> 16k, 1200000 -> 1.2M
const trim = (x) => x.toFixed(1).replace(/\.0$/, "");
function tok(n) {
  if (n == null) return "?";
  if (n >= 1e6) return trim(n / 1e6) + "M";
  if (n >= 1e4) return Math.round(n / 1e3) + "k";
  if (n >= 1e3) return trim(n / 1e3) + "k";
  return String(n);
}

// progress gauge with 1/8-cell resolution — 10 cells give 80 visible steps
const EIGHTHS = ["", "▏", "▎", "▍", "▌", "▋", "▊", "▉"];
function bar(p, width) {
  const v = Math.max(0, Math.min(100, p));
  const eighths = Math.round((v / 100) * width * 8);
  const full = Math.floor(eighths / 8);
  const part = eighths % 8;
  const empty = Math.max(0, width - full - (part ? 1 : 0));
  const lit = "█".repeat(full) + EIGHTHS[part];
  return (lit ? fg(heat(v), lit) : "") + (empty ? fg(CLR.track, "░".repeat(empty)) : "");
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

// current git branch (or short SHA when detached); null if not a repo.
// execFileSync, not execSync — no shell in the hot path, this runs every refresh.
function git(args, cwd) {
  return execFileSync("git", args, {
    cwd,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "ignore"],
    timeout: 800,
  }).trim();
}
function gitBranch(cwd) {
  if (!cwd) return null;
  try {
    return git(["symbolic-ref", "--short", "-q", "HEAD"], cwd) || null;
  } catch {
    /* detached HEAD */
  }
  try {
    return git(["rev-parse", "--short", "HEAD"], cwd) || null;
  } catch {
    return null;
  }
}

// one usage window; renders "—" when the server omitted that bucket so an
// absent limit reads as "no data" instead of silently vanishing
function quota(label, q, withReset) {
  const head = fg(CLR.label, label + " ");
  if (q?.used_percentage == null) return head + fg(CLR.track, "—");
  const r = withReset ? until(q.resets_at) : "";
  return head + pct(Math.round(q.used_percentage)) + (r ? dim(" ↻" + r) : "");
}

// ── layout ────────────────────────────────────────────────────
// Every segment carries four renderings, richest first, and a priority.
// Shrinking happens in two phases, mirroring how flex containers give up
// space: first every segment steps down a detail level together, and only
// when the tightest level still overflows do whole segments get dropped,
// lowest priority first. An empty variant means "gone at this level".
//
//   L0  everything
//   L1  shed decorations — session name, agent, vim mode, worktree tag
//   L2  shed precision   — shorter gauge, no reset countdowns, no window size
//   L3  shed structure   — no gauge, clipped names, labels implied by glyphs
const LEVELS = 4;

const compose = (segs, lvl) =>
  segs
    .map((s) => s.v[Math.min(lvl, s.v.length - 1)])
    .filter(Boolean)
    .join(SEP);

function fit(segs, budget) {
  let line = "";
  for (let lvl = 0; lvl < LEVELS; lvl++) {
    line = compose(segs, lvl);
    if (vwidth(line) <= budget) return line;
  }
  const live = segs.map((s) => ({ prio: s.prio, text: s.v[s.v.length - 1] })).filter((s) => s.text);
  while (live.length > 1) {
    let worst = 0;
    for (let i = 1; i < live.length; i++) if (live[i].prio < live[worst].prio) worst = i;
    live.splice(worst, 1);
    line = live.map((s) => s.text).join(SEP);
    if (vwidth(line) <= budget) return line;
  }
  return line;
}

function buildSegments(d) {
  const segs = [];
  const cwd = d.workspace?.current_dir || d.cwd;

  // ── session name (only when set via /rename) ──
  if (d.session_name) segs.push({ prio: 1, v: [fg(CLR.label, d.session_name), ""] });

  // ── model (+ effort / fast / thinking / agent / vim) ──
  const name = d.model?.display_name || "?";
  let core = bold(CLR.model, name);
  if (d.effort?.level) core += dim("·" + d.effort.level);
  if (d.fast_mode) core += fg(CLR.fast, "·fast");
  if (d.thinking?.enabled) core += " " + fg(CLR.think, "✦");
  let full = core;
  if (d.agent?.name) full += " " + fg(CLR.agent, "@" + d.agent.name);
  if (d.vim?.mode) full += " " + fg(CLR.tree, d.vim.mode[0]);
  segs.push({ prio: 8, v: [full, core, core, bold(CLR.model, clip(name, 12))] });

  // ── branch + worktree + PR (path intentionally omitted) ──
  const branch = gitBranch(cwd);
  const b = branch ? fg(CLR.branch, branch) : "";
  // git_worktree is the worktree *name*, not a branch — keep it as its own tag
  const wt = d.workspace?.git_worktree ? fg(CLR.tree, "▸" + d.workspace.git_worktree) : "";
  const pr = d.pr?.number ? fg(PR_CLR[d.pr.review_state] ?? CLR.dim, "#" + d.pr.number) : "";
  const wide = [b, wt, pr].filter(Boolean).join(" ");
  if (wide) {
    const mid = [b, pr].filter(Boolean).join(" ");
    segs.push({ prio: 5, v: [wide, mid, mid, branch ? fg(CLR.branch, clip(branch, 14)) : ""] });
  }

  const cw = d.context_window;

  // ── context window ──
  const ctxL = fg(CLR.label, "ctx ");
  if (cw?.used_percentage != null) {
    const p = Math.round(cw.used_percentage);
    const w10 = ctxL + bar(p, 10) + " " + pct(p);
    segs.push({ prio: 9, v: [w10, w10, ctxL + bar(p, 6) + " " + pct(p), ctxL + pct(p)] });
  } else {
    const none = fg(CLR.track, "   —");
    const w10 = ctxL + fg(CLR.track, "░".repeat(10)) + none;
    segs.push({
      prio: 9,
      v: [w10, w10, ctxL + fg(CLR.track, "░".repeat(6)) + none, ctxL + fg(CLR.track, "—")],
    });
  }

  // ── token io ──
  // total_input_tokens is everything occupying the window (fresh + cache
  // create + cache read). total_output_tokens is the most recent response
  // only — the payload carries no cumulative output figure.
  if (cw) {
    const ioL = fg(CLR.label, "io ");
    const down = fg(CLR.tokIn, "↓" + tok(cw.total_input_tokens));
    const up = fg(CLR.tokOut, "↑" + tok(cw.total_output_tokens));
    const size = dim("/" + tok(cw.context_window_size || 200000));
    const wide = ioL + down + size + " " + up;
    segs.push({ prio: 4, v: [wide, wide, ioL + down + " " + up, down + " " + up] });
  }

  // ── usage limits ──
  // Subscription-only: the whole key is absent on API-key/Bedrock/Vertex
  // sessions where plan limits do not apply. Individual windows can also be
  // missing when the API response carries no matching ratelimit header.
  const rl = d.rate_limits;
  if (rl) {
    const f = rl.five_hour;
    const w = rl.seven_day;
    // when narrow, keep only the window closest to its ceiling — that is the
    // one that will actually stop you
    const tight = (w?.used_percentage ?? -1) > (f?.used_percentage ?? -1);
    const wide = quota("5h", f, true) + DOT + quota("wk", w, true);
    segs.push({
      prio: 6,
      v: [
        wide,
        wide,
        quota("5h", f, false) + DOT + quota("wk", w, false),
        tight ? quota("wk", w, false) : quota("5h", f, false),
      ],
    });
  }

  return segs;
}

function render(d) {
  return " " + fit(buildSegments(d), COLS - 2);
}
