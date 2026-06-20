# Fix the tmux 3.6a copy-mode double-free crash on macOS / Apple Silicon.
#
# Upstream bug : https://github.com/tmux/tmux/issues/4777
# Fix commit   : 035a2f35d40628dcfe235179220fc0ede848a195 (on master, not in any
#                release yet — 3.6a is still the latest tag, so nixpkgs ships the
#                buggy version even on nixpkgs-unstable).
#
# Cause: grid_trim_history() memmove()s the line array but left the tail entries
# pointing at already-freed lines. Entering copy-mode (window_copy_clone_screen
# -> screen_reinit -> grid_clear_lines -> grid_free_line) then freed those
# dangling pointers again -> double-free -> SIGABRT. Triggered by mouse scroll or
# any copy-mode keybinding, and only after history has been trimmed (i.e. in
# long-running sessions). The fix memset()s the trimmed tail to zero.
#
# This is written as a real overlay (final: prev:) rather than a package under
# overlays/<dir>/ because it OVERRIDES an existing package and must reference
# prev.tmux. The directory-based overlays/default.nix uses callPackage, which
# resolves the `tmux` argument against the final package set -> infinite
# recursion. overlays/default.nix only scans directories, so this .nix file is
# ignored there; it is wired in explicitly via flakeOverlays in flake.nix.
final: prev: {
  tmux = prev.tmux.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (prev.fetchpatch {
        name = "tmux-4777-grid-trim-history-double-free.patch";
        url = "https://github.com/tmux/tmux/commit/035a2f35d40628dcfe235179220fc0ede848a195.patch";
        hash = "sha256-N4w+LMj1fLGcxonHWoIeH8abogSwQFJsdfPI7w6RTCI=";
      })
    ];
  });
}
