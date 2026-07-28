# Nvim Image Viewing via snacks.image

## Problem

Viewing images inside Neovim (inline markdown, image file buffers, floating
windows) fails inside tmux because Kitty's native image protocol does not pass
through tmux < 3.5.

## Setup

- **Terminal**: Kitty 0.48.1
- **Multiplexer**: tmux 3.7b
- **Editor**: nixvim with plugins loaded via `vim.pack`
- **Relevant installed plugins**: `snacks.nvim`, `render-markdown.nvim`,
  `img-clip.nvim`
- **Existing config**: tmux has `set -g allow-passthrough all`; kitty has
  `allow_remote_control yes`

## Solution

Enable `snacks.image` — the image viewer built into the already-installed
`snacks.nvim`. It uses the Kitty Graphics Protocol natively. With tmux >= 3.5
(we have 3.7b) the protocol passes through tmux correctly, so images render in
both direct Kitty sessions and inside tmux panes.

Mọi image rendering goes through snacks.image:
- Markdown buffers → inline images (png/jpg/gif etc.)
- Opening image files → dedicated image buffer
- `:Snacks.image.hover()` → floating window at cursor
- LaTeX math expressions in markdown/latex documents

### Changes

**File 1: `home-manager/programs/nvim/lua/plugins/snacks.lua`**

Add the `image` module to `snacks.setup()`:

```lua
{
  enabled = true,
  doc = {
    enabled = true,
    inline = true,   -- inline image trong buffer
    float = true,    -- fallback floating window
    max_width = 80,
    max_height = 40,
  },
  img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments" },
}
```

**File 2: `home-manager/programs/nvim/default.nix`**

Add `imagemagick` to `home.packages`. Required by snacks.image for format
conversion (jpg/gif/webp/pdf/svg → PNG).

### Non-Goals

- Not switching terminal emulator (keeping Kitty).
- Not adding a separate image plugin (`3rd/image.nvim` not needed since
  Kitty protocol works through tmux 3.7b).

## Verification

1. `nix eval --impure .#homeConfigurations.macmini.activationPackage.drvPath`
   — confirms build succeeds.
2. Open a markdown file with `![alt](img/foo.png)` → image renders inline.
3. `:Snacks.image.hover()` on an image path → floating window shows image.
4. Open a `.png` file → dedicated image buffer.
5. Run `:checkhealth snacks` inside nvim to confirm no warnings.
