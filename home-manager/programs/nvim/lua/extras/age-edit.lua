local repo = vim.fn.expand("~/.nix")

local function run_agenix(rel)
	local bufnr = vim.api.nvim_get_current_buf()
	vim.fn.termopen("cd " .. repo .. " && agenix -e " .. rel, {
		on_exit = function()
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end,
	})
end

vim.api.nvim_create_user_command("AgeEdit", function()
	local file = vim.fn.expand("%:p")
	if file:match("%.age$") then
		local prefix = repo .. "/"
		local rel = file:sub(1, #prefix) == prefix and file:sub(#prefix + 1) or vim.fn.fnamemodify(file, ":t")
		vim.cmd("enew")
		run_agenix(rel)
	else
		require("telescope.builtin").find_files({
			cwd = repo,
			prompt_title = "Age Secrets",
			find_command = { "find", ".", "-name", "*.age", "-not", "-path", "./.git/*" },
			attach_mappings = function(_, m)
				m("i", "<CR>", function(buf)
					local entry = require("telescope.actions.state").get_selected_entry(buf)
					require("telescope.actions").close(buf)
					local rel = entry[1]:gsub("^%./", "")
					vim.cmd("enew")
					run_agenix(rel)
				end)
				return true
			end,
		})
	end
end, { desc = "Edit age-encrypted secrets" })
