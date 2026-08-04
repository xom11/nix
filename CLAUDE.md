# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## This repo is public

`xom11/nix` on GitHub, visibility **PUBLIC**. Git history is permanent — deleting
something in a later commit does not unpublish it. Every write here is a publish,
and that includes commit messages, code comments, docs, and PR/issue text.

Never commit:

- **Credentials** — keys, tokens, passwords, session cookies. `.age` files are
  ciphertext and belong here; whatever they decrypt to does not.
- **Private identifiers** — internal hostnames, LAN/Tailscale addresses, serial
  numbers, personal email or phone, paths that expose who or where someone is.
- **Real values in examples.** Commands, comments and docs use placeholders
  (`$TOKEN`, `user@host`), never a working credential — not even an expired one.
- **Unredacted machine output** — logs, `env` dumps, error traces, screenshots.
  Capture is not review; read it before pasting it in.
- **Shell metacharacters inside secret values.** `apikey.zsh.age` is read by zsh
  *and* by a deliberately simple PowerShell parser on Windows, and the two
  disagree. `$`, a backtick or `$(...)` expands on one side and stays literal on
  the other. Quotes diverge too: zsh concatenates adjacent quoted words, so
  `"say ""hi"""` is `say hi` and `'it'\''s'` is `it's`, while the Windows parser
  strips only the outer pair and keeps the rest verbatim. Either way one machine
  gets the real value and the other a corrupted one, with nothing to warn you.
  Values are literal text containing none of `$`, backtick, `$(...)`, `'`, `"`.

- **Measurements taken from live secrets.** Counts, value lengths, character
  inventories, "all 14 comply" — these describe real secret material and are as
  publishable as the values themselves. Verify against live data all you like;
  write only the verdict, never the numbers. This rule exists because a design
  doc here once published the character set of every real API key.

**`docs/` is a public website, not just files.** `.github/workflows/docs.yml`
runs `mkdocs build` on every push to `main`, and `mkdocs.yml` has no `nav:` — so
**every** `.md` under `docs/` is deployed to `xom11.github.io/nix` and indexed
for search, whether or not anything links to it. A file being "just notes" is not
a defence. `docs/superpowers/` is gitignored for exactly this reason: AI-written
specs and plans quote whatever was measured while verifying, and that is usually
live data.

Secrets in this repo decrypt to paths *outside* the tree (`~/.ssh/age.d/`,
`~/.config/zsh/apikey.zsh`). Keep it that way — never write plaintext under `~/.nix`.

Read `git diff --cached` before committing; a glob check is not enough. If a
credential does land in a commit, **rotate it** — the push is already public, so
rewriting history alone does not fix anything.

### The guards, and what each one cannot see

Four layers, deliberately non-overlapping. Knowing the gap in each is the point —
a guard you trust past its range is worse than none.

| Guard | Where | Sees | Blind to |
|---|---|---|---|
| `.githooks/pre-push` | your machine, at push | values that **are** in `apikey.zsh`, in **every commit** of the range | a key not in `apikey.zsh` yet |
| `.github/scripts/check-placeholders.sh` | CI | credential fields under `home-manager/dotfiles/` that hold a literal | anything outside that tree; deleted-before-push |
| `gitleaks` + `.gitleaks.toml` | CI | known patterns in the pushed range | whatever no pattern describes — it missed the real key here |
| GitHub push protection | GitHub | partner patterns | self-issued keys; a public repo gets no `non_provider_patterns` |

The hook compares **exactly** against decrypted secrets — no entropy guessing —
and reads `git log -p --cc` per commit, never `git diff`: adding then deleting
before a push leaves a clean overall diff and a permanent commit. It prints only
variable **names**. Bypass one push with `git push --no-verify`.

Inside a diff it reads **added lines only**. A `-` line means the value is in an
earlier commit — either inside the range, where its `+` was already caught, or
outside it, where it is already pushed. Blocking there would only block the
cleanup commit. `.githooks/allow-vars` exempts variables whose value is
deliberately public (`ROUTER_ENDPOINT` is a Tailscale address). Prefer adding a
name there over reaching for `--no-verify`, which drops the whole fence.

It gets its values from `~/.config/zsh/apikey.zsh`, the Windows `apikey.ps1`, and
by decrypting `age.d/apikey.zsh.age` in memory. If it finds none, it blocks only
when this machine's key is in `programs/ssh/authorized_keys` — a machine that is
supposed to decrypt and cannot is a broken fence, not a clean repo. On the other
eight hosts it says so and steps aside.

`core.hooksPath` is set by `home.activation` (nix) and
`windows/modules/programs/githooks` (Windows), so a rebuild installs it. It must
stay **absolute**: git resolves a relative `core.hooksPath` against the current
directory, so `git push` from a subdirectory would silently run no hook.

Run any of them by hand: `./.githooks/…` via `.github/scripts/test-prepush.sh`,
`./.github/scripts/check-placeholders.sh [--self-test]`.

## Rebuild Commands

`--impure` is required everywhere: `lib/mkConfigs.nix` reads `$USER`/`$SUDO_USER`
and `builtins.currentSystem` at eval time.

```bash
# macOS (nix-darwin) — also available as shell alias `update`
sudo darwin-rebuild switch --impure --flake ~/.nix#macmini
sudo darwin-rebuild switch --impure --flake ~/.nix#airm3

# NixOS
sudo nixos-rebuild switch --impure --flake ~/.nix#x1g6
sudo nixos-rebuild switch --impure --flake ~/.nix#vmware

# Standalone home-manager
home-manager switch --impure -b backup --flake ~/.nix#server     # also: rog, desktop, a14, minimal

# system-manager (system-level config on a non-NixOS Linux distro)
sudo nix run 'github:numtide/system-manager' -- switch --flake ~/.nix#a14   # also: desktop
```

## Checking a host without rebuilding it

`--system` overrides `builtins.currentSystem`, so any host can be evaluated from
any machine. This is what CI does (`.github/workflows/eval.yml`), and it is the
fastest way to know whether a change breaks a host you are not sitting at:

```bash
nix eval --impure --system x86_64-linux  .#homeConfigurations.desktop.activationPackage.drvPath
nix eval --impure --system aarch64-linux .#nixosConfigurations.vmware.config.system.build.toplevel.drvPath
nix eval --impure                        .#darwinConfigurations.macmini.system.drvPath
```

`nix flake check` does **not** work here — it evaluates purely and dies on
`builtins.currentSystem`. Use the per-host `nix eval --impure` above instead.

`nix fmt` (alejandra) and `nix develop` (alejandra, nixd, deadnix, statix) are wired up.

## Architecture

### Flake outputs

`flake.nix` defines outputs via thin wrappers in `lib/mkConfigs.nix`:

| Builder | Outputs |
|---|---|
| `lib.mkDarwin` | `darwinConfigurations.{macmini,airm3}` |
| `lib.mkNixos` | `nixosConfigurations.{x1g6,vmware}` |
| `lib.mkHomeManager` | `homeConfigurations.{rog,server,desktop,a14,minimal}` |
| `lib.mkSystemManager` | `systemConfigs.<system>.{desktop,a14}` — keyed by system (`aarch64-linux`, `x86_64-linux`) |

`mkDarwin`/`mkNixos` wire home-manager in as a module (`useGlobalPkgs = true`, so
home-manager reuses the system `pkgs` rather than instantiating nixpkgs twice).
`mkHomeManager` builds its own `pkgs`. All four apply the same overlay list
(`allOverlays` = `overlays/` + the overlays shipped by flake inputs), so
`pkgs.<tool>` resolves identically under every builder.

Each builder wires `hosts/{device}/configuration.nix` and/or `hosts/{device}/home.nix`.
Standalone home-manager hosts have only `home.nix`.

### Special args

All modules receive these extra args (defined in `lib/mkConfigs.nix`):

- `device` — string name of the current host
- `username` — detected from `$SUDO_USER`/`$USER` at eval time, falls back to `"kln"`
- `homeDir` — `/Users/$username` on darwin, `/home/$username` on linux
- `repoPath` — always `$homeDir/.nix`; every `mkOutOfStoreSymlink` points here, so
  it must be a writable working tree (`home-manager/base` clones it on first switch)
- `getRelPath path` — the module's path relative to the repo root
- `getPath path` — converts a Nix store path back to its real filesystem path under `repoPath`
- `autoImport dir` — every nested `default.nix` under `dir`, except `dir`'s own
- `mkModule`, `ckModule` — module helpers (see below)
- plus every flake input, by name

`mkSystemManager` deliberately passes a **reduced** set (`device`, `system`,
`autoImport`, `mkModule`, `ckModule`) — splatting `inputs` there would shadow
system-manager's own `_module.args.system-manager` with the flake input of the
same name.

### Per-host module lists

Each `hosts/*/home.nix` carries its full `modules.home-manager.*.enable` list —
there is deliberately **no shared profile layer** (one existed briefly and was
removed; the owner prefers each host to read as a complete inventory). The
corollary: renaming or removing a module means updating every host that enables
it, and nothing but CI will tell you a host was missed. After touching any
module's directory name or any host file, run the per-host eval check (see
"Checking a host" above) — CI (`.github/workflows/eval.yml`) runs the same
checks on push.

The common toolkit currently enabled on almost every host, for orientation:
`programs.{btop,git,herdr,nvim,ssh,tmux,yazi,zsh}` + `pkgs.{dev,lang,tools}`.
When adding a module that every host should get, add it to each host file.

### mkModule pattern

Every module in `home-manager/`, `nixos/`, `nix-darwin/` and `system-manager/`
uses one of three styles. Style 3 is by far the most common (~52 modules); style 2
exists only because `mkModule` cannot declare options beyond `enable` (~4 modules,
all under `nixos/services/environments/`); style 1 is a single leftover.

```nix
# Style 1 — manual enable option
{ config, lib, ... }:
let cfg = config.modules.gnome; in
{ options.modules.gnome.enable = lib.mkEnableOption "gnome"; config = lib.mkIf cfg.enable { ... }; }

# Style 2 — path-derived option path, plus extra options
{ config, lib, getRelPath, ... }:
let relPath = getRelPath ./.; pathList = ["modules"] ++ lib.splitString "/" relPath;
    cfg = lib.getAttrFromPath pathList config;
in { options = lib.setAttrByPath pathList { enable = ...; type = ...; }; config = lib.mkIf cfg.enable { ... }; }

# Style 3 — function shorthand (use this)
{ config, mkModule, ... }:
mkModule config ./. { ... }
```

`mkModule config path content`:
1. Derives the option path from the module's filesystem path
2. Declares `enable` there
3. Wraps `content` in `lib.mkIf cfg.enable`

**The option path mirrors the directory path exactly, including intermediate
directories.** This is the single most common source of broken host files:

| Module directory | Option path |
|---|---|
| `home-manager/programs/zsh` | `modules.home-manager.programs.zsh.enable` |
| `home-manager/dotfiles/terminal/kitty` | `modules.home-manager.dotfiles.terminal.kitty.enable` — **not** `dotfiles.kitty` |
| `home-manager/dotfiles/browser/qutebrowser` | `modules.home-manager.dotfiles.browser.qutebrowser.enable` |
| `home-manager/dotfiles/ai/claude.d` | `modules.home-manager.dotfiles.ai."claude.d".enable` — the dot must be quoted |
| `nixos/services/keyd` | `modules.nixos.services.keyd.enable` — **not** `modules.services.keyd` |

Before writing an `enable = true` into a host, confirm the directory exists.
`find home-manager nixos nix-darwin system-manager -name default.nix` is the source of truth.

### Module tree

```
nix-darwin/          # macOS system: base, brew, launchd/kanata, setting
nixos/               # NixOS system: base, programs, systemPackages,
                     #   services/{environments,hibernate,ibus,kanata,keyd}
system-manager/      # system-level config on non-NixOS Linux (a14, desktop):
                     #   base, etc/trackpad, services/{docker,kanata,keyd,openssh}
home-manager/
  base/              # username, homeDir, stateVersion, sessionVariables
                     #   + macos/, ubuntu/, nixos/ — each carries that platform's `update` alias
  programs/          # btop, git, herdr, nvim, ssh, tmux, yazi, zsh
                     #   herdr: config only -- the binary is installed out-of-band,
                     #   pkgs.herdr does not build on darwin (zig/DarwinSdkNotFound)
  dotfiles/          # ai/{aichat.d,claude.d,codex.d,gemini.d,opencode.d}
                     #   claude.d: MCP user-scope lives in ~/.claude.json, which Claude
                     #   Code rewrites -- not symlinkable, and settings.json takes no
                     #   mcpServers key. So each machine needs it added out-of-band:
                     #     claude mcp add --transport http --scope user pixellab \
                     #       https://api.pixellab.ai/mcp \
                     #       --header 'Authorization: Bearer ${PIXELLAB_TOKEN}'
                     #   Single quotes, and URL before --header (it is variadic).
                     # browser/{firefox,qutebrowser}, terminal/{alacritty,kitty}
                     # macos/{aerospace,hammerspoon,karabiner,sleepwatcher}
                     # conda, rofi, run-or-raise, vscode
  environments/      # fonts, gnome, i18n, i3wm, sway, wayland
  pkgs/              # dev, lang, nixos, tools, ubuntu
  services/          # agenix, syncthing
overlays/            # local packages: fcitx5-macos, neofetch2, raiseorlaunch
hosts/{device}/      # per-device configuration.nix and/or home.nix
configs/             # non-Nix: ansible playbooks, kanata layouts
windows/             # live parallel PowerShell config; reuses the shared dotfiles
                     #   under home-manager/dotfiles via links.ps1. Not orphaned.
```

Modules are auto-discovered — `home-manager/default.nix` (and the equivalent in
`nixos/`, `nix-darwin/`, `system-manager/`) is just `imports = autoImport ./.`,
which pulls in every nested `default.nix`. There is no import list to update, but
note the corollary: a module nobody enables still has its options declared on
every rebuild. That is cheap (the body sits behind `mkIf cfg.enable`), so keeping
an unused module around for reference is fine — but a **broken** one is a landmine,
since enabling it is all it takes to break eval.

### Dotfile linking pattern

Dotfiles are kept as real files in the repo and symlinked at activation time (so
edits take effect without rebuilding):

```nix
home.file."${config.xdg.configHome}/zsh/zsh.d" = {
  source = config.lib.file.mkOutOfStoreSymlink "${getPath ./.}/zsh.d";
};
```

The symlink target is a plain string, so it is **not** a reference of the
home-manager generation. It must point into the `~/.nix` working tree — never into
the store, or the dotfiles are read-only and get collected on the next GC.

### dotbrave: one file, two readers, two different times

`home-manager/dotfiles/browser/dotbrave/brave.toml` carries three tables
(`[shortcuts]`, `[settings]`, `[pwa]`), but nothing reads all three — and the
two things that do read it read at **different times**. That asymmetry is
invisible at a glance and tends to be discovered the hard way:

- `[shortcuts]` and `[settings]` are read by the `dotbrave` CLI at
  **activation** (`programs.dotbrave` in
  `home-manager/dotfiles/browser/dotbrave/default.nix`, enabled on macmini).
  The activation script embeds the *path* to `brave.toml`, not its contents,
  so editing those tables changes no derivation — a switch applies them
  without rebuilding anything.
- `[pwa]` is read by Nix itself, via `builtins.fromTOML`, at **evaluation**
  (`services.dotbrave` in `hosts/macmini/configuration.nix`; the module comes
  from `dotbrave.darwinModules.default`). Editing the PWA list edits an *input
  to eval*, so the switch rebuilds the plist. A malformed entry fails
  evaluation, taking the whole switch down before anything is applied.

**This is not the "edit without rebuilding" pattern** the section above
describes, and conflating the two is the easy mistake. A symlinked dotfile
like `zsh.d` needs no switch at all — the program reads the file directly.
Both dotbrave tables need *something to run the CLI*, and the CLI only runs at
activation. So:

| | Needs a switch? | Rebuilds anything? | Appliable outside Nix? |
|---|---|---|---|
| symlinked dotfile | no | no | yes, the program reads it |
| `[shortcuts]`, `[settings]` | **yes** | no | yes, `dotbrave apply --skip pwa` |
| `[pwa]` | **yes** | yes, a new plist | no, Nix owns it |

The agenix analogy one section below still holds for the *eval-vs-runtime*
half: changing a secret's contents needs no switch, but adding one does.
Do not stretch it further than that — agenix decrypts from a launchd agent,
so its contents really do apply without a switch. Nothing here does.

In practice on macmini there is a third gate: Brave is usually open, and the
CLI skips `[shortcuts]`/`[settings]` rather than closing it. Those tables
therefore only land when Brave is closed *and* something runs the CLI.

Why `[pwa]` is the odd one out: the home-manager module declares
`skip = [ "pwa" ]`, so the CLI never builds a plan for that table. The CLI runs
as you (home-manager activation), but force-installing a PWA means writing a
managed-policy file, which needs root. Handing that one table to Nix
(`darwin-rebuild` already runs as root) avoids an interactive sudo prompt in
the middle of an activation — the "never ask for sudo mid-rebuild" rule this
repo follows everywhere else.

**A manual run must repeat the skip**:

```bash
dotbrave apply --skip pwa home-manager/dotfiles/browser/dotbrave/brave.toml
```

A bare `dotbrave apply` also builds a `[pwa]` plan, and that namespace belongs
to the system module. The CLI would write the same managed policy as a second
owner, from your user account, prompting for sudo. It is harmless today only
because both writers happen to emit byte-identical output; the moment they
diverge, whichever ran last wins and the next rebuild silently reverts it.

**The other surprise:** the CLI skips `[shortcuts]`/`[settings]` when it finds
**no live DevTools endpoint** for a running Brave — not merely "because Brave
is running". With an endpoint it live-applies to the running browser and skips
nothing. Under `--unattended` (how activation invokes it) a missing endpoint
means skip rather than close Brave, deliberately: an activation must not
interrupt an open session. A second, narrower skip exists for settings Brave
cannot change live. In practice Brave runs here without an endpoint, so those
two tables only really land while Brave is closed — a "successful" activation
does **not** mean the shortcut policy was applied. The activation entry also
swallows failures (`|| echo "dotbrave: apply failed, continuing activation"`),
so read its output rather than trusting the switch's exit status.

### Secrets (agenix)

Secrets get the same "edit without rebuilding" property, but by a different
route — `.age` is ciphertext, so a symlink alone is no good and a decrypt step
has to run. Two rules make that work:

```nix
file = "${pwd}/age.d/apikey.zsh.age";   # string, NOT ./age.d/apikey.zsh.age
```

A path literal copies the ciphertext into the store and freezes it there until
the next switch. `types.path` accepts an absolute-path string and leaves it
alone, so the decrypt reads the working tree. Every `age.secrets.<n>.file` in
this repo must be written that way.

`agenix-reload <file.age>` then re-decrypts into wherever that secret installs.
The nvim `age-edit` plugin calls it on `:w`, so editing a secret there applies
immediately; after `agenix -e` or a `git pull`, run it by hand. The mapping is
generated from `age.secrets`, so **adding** a secret still needs a switch —
only changing one's contents does not.

Note `age.secrets` is consumed by a launchd agent (systemd unit on linux), not
by `home.activation` — so a decrypt that fails never fails the switch, it just
lands in `~/Library/Logs/agenix/stderr`.

`home-manager/programs/agenix` pins that agent's `KeepAlive` to
`{ SuccessfulExit = false; }` and its `ThrottleInterval` to 60. agenix ships
`Crashed = false` alongside `SuccessfulExit`, which relaunches the job every
~10s forever; dropping the whole key instead would also lose the retry that
lets a fresh machine heal itself once the real `~/.ssh/id_ed25519` is dropped
in (its own generated key decrypts nothing). That retry is blind, so a host
with no usable key logs 425 bytes a minute until one appears — the throttle is
what keeps that at ~600 KB/day rather than ~3.7 MB.

### Adding a new module

1. Create `home-manager/<category>/<name>/default.nix` using `mkModule config ./. { ... }`
2. Enable it per-device in `hosts/{device}/home.nix` under
   `modules.home-manager.<category>.<name>.enable = true` (in every host file,
   if every host should get it)
3. Confirm the hosts you touched still evaluate (see "Checking a host" above)

## Git

- Do NOT add `Co-Authored-By` lines to commit messages.
