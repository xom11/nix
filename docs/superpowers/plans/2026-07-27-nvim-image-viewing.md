# Nvim Image Viewing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable inline image rendering in Neovim via `snacks.image` (Kitty Graphics Protocol through tmux 3.7b passthrough).

**Architecture:** Two changes to existing files in the nixvim config: (1) enable the `image` module inside `snacks.setup()`, (2) add `imagemagick` to nix `home.packages` for format conversion.

**Tech Stack:** nixvim, snacks.nvim (already installed), imagemagick

## Global Constraints

- Kitty protocol works through tmux 3.7b with `allow-passthrough all`
- `imagemagick` required for non-PNG image formats (jpg/gif/webp/pdf/svg)
- Already have `set -g allow-passthrough all` in tmux config — no tmux changes needed
- Already have `allow_remote_control yes` in kitty config — no kitty changes needed

---

### Task 1: Enable snacks.image with document integration

**Files:**
- Modify: `home-manager/programs/nvim/lua/plugins/snacks.lua:2-5`

**Interfaces:**
- Consumes: existing `require("snacks").setup({...})` call
- Produces: same call with `image = {...}` added

- [ ] **Step 1: Add `image` config to `snacks.setup()`**

Current content of `lua/plugins/snacks.lua`:
```lua
vim.pack.add({ { src = "https://github.com/folke/snacks.nvim" } }, { load = true, confirm = false })
require("snacks").setup({
	notifier = {
		enabled = true,
	},
	-- snacks.picker/explorer stay off -- telescope and neo-tree own that.
	-- These two are just free: bigfile turns off treesitter/LSP/syntax on huge
	-- files instead of hanging, quickfile paints the buffer before plugins load.
	bigfile = { enabled = true },
	quickfile = { enabled = true },
})

-- Macro recording notifications
vim.api.nvim_create_autocmd("RecordingEnter", {
	callback = function()
		vim.notify("Recording @" .. vim.fn.reg_recording(), vim.log.levels.INFO, { title = "Macro" })
	end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
	callback = function()
		Snacks.notifier.hide()
		vim.notify("Recording stopped", vim.log.levels.INFO, { title = "Macro" })
	end,
})
```

Replace with:
```lua
vim.pack.add({ { src = "https://github.com/folke/snacks.nvim" } }, { load = true, confirm = false })
require("snacks").setup({
	notifier = {
		enabled = true,
	},
	-- snacks.picker/explorer stay off -- telescope and neo-tree own that.
	-- These two are just free: bigfile turns off treesitter/LSP/syntax on huge
	-- files instead of hanging, quickfile paints the buffer before plugins load.
	bigfile = { enabled = true },
	quickfile = { enabled = true },
	image = {
		enabled = true,
		doc = {
			enabled = true,
			inline = true,
			float = true,
			max_width = 80,
			max_height = 40,
		},
		img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments" },
	},
})

-- Macro recording notifications
vim.api.nvim_create_autocmd("RecordingEnter", {
	callback = function()
		vim.notify("Recording @" .. vim.fn.reg_recording(), vim.log.levels.INFO, { title = "Macro" })
	end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
	callback = function()
		Snacks.notifier.hide()
		vim.notify("Recording stopped", vim.log.levels.INFO, { title = "Macro" })
	end,
})
```

- [ ] **Step 2: Verify syntax**

Run: `nvim --headless -c "luafile ~/.config/nvim/lua/plugins/snacks.lua" -c "qa"` (or just check the file reads cleanly in the current nvim when rebuilt).

- [ ] **Step 3: Commit**

```bash
git add home-manager/programs/nvim/lua/plugins/snacks.lua
git commit -m "feat(nvim): enable snacks.image for inline image rendering
```

---

### Task 2: Add imagemagick package

**Files:**
- Modify: `home-manager/programs/nvim/default.nix:20-35`

**Interfaces:**
- Consumes: existing `home.packages = with pkgs; [ ... ]` list
- Produces: same list with `imagemagick` added

- [ ] **Step 1: Add `imagemagick` to `home.packages`**

Current relevant section:
```nix
    home.packages = with pkgs; [
      # conform formatters
      black
      shfmt
      ...
    ];
```

Add `imagemagick` to the list (anywhere, but logically with the tooling section):
```nix
    home.packages = with pkgs; [
      # image format conversion (snacks.image needs this for non-PNG)
      imagemagick

      # conform formatters
      black
      shfmt
      ...
    ];
```

- [ ] **Step 2: Verify eval**

Run: `nix eval --impure .#homeConfigurations.macmini.activationPackage.drvPath`
Expected: returns a store path, no errors.

- [ ] **Step 3: Commit**

```bash
git add home-manager/programs/nvim/default.nix
git commit -m "feat(nvim): add imagemagick for snacks.image format conversion"
```
