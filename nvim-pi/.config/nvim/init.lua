-- Minimal Neovim config for the Raspberry Pi.
-- No plugins, no runtimes: only what ships with Neovim 0.12.

local keymap = vim.keymap.set
local opts = { silent = false }

-- Leader must be set before any <leader> mappings
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-- Disable unused providers
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- appearance
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.title = true
vim.opt.titlestring = "%<%F%=%l/%L"
vim.opt.colorcolumn = "80"

-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8

-- search
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.mouse = "a"

-- tabs & indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true

vim.opt.wrap = false
vim.opt.splitright = true
vim.opt.timeoutlen = 300
vim.opt.undofile = true -- default undodir: stdpath("state")/undo
vim.opt.fileencoding = "utf-8"

-- Send yanks to the Mac clipboard over SSH/tmux
vim.g.clipboard = "osc52"

-- Caddyfile: sudoedit edits a temp copy named like /var/tmp/CaddyfileAb3dEf9Z
vim.filetype.add({
	pattern = {
		["Caddyfile.*"] = "caddy",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "caddy",
	callback = function()
		vim.bo.commentstring = "# %s"
	end,
	desc = "Use # comments in Caddyfiles",
})

-- sudoedit temp files get a random name each time, so their undo files
-- can never be reloaded and would just pile up on the SD card
vim.api.nvim_create_autocmd("BufReadPre", {
	pattern = "/var/tmp/*",
	callback = function()
		vim.bo.undofile = false
	end,
	desc = "No persistent undo for sudoedit temp files",
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 40 })
	end,
	desc = "Highlight yanked text",
})

-- Must be defined before the colorscheme is set so it fires on startup
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		for _, name in ipairs({ "Normal", "NormalNC", "SignColumn", "EndOfBuffer", "MsgArea" }) do
			vim.cmd.highlight(name .. " ctermbg=none guibg=none")
		end
	end,
	desc = "Remove backgrounds for transparency",
})

vim.cmd.colorscheme("default")

-- Keymaps

-- Resize with arrows
keymap("n", "<A-Up>", ":resize -2<CR>", opts)
keymap("n", "<A-Down>", ":resize +2<CR>", opts)
keymap("n", "<A-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<A-Right>", ":vertical resize +2<CR>", opts)

keymap("i", "jk", "<ESC>", opts)

-- Keep selection when indenting
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

keymap("x", "<leader>p", [["_dP]], { desc = "Paste without losing register" })
keymap({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
keymap("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })
keymap("n", "<leader>ya", "<cmd>%y+<CR>", { desc = "Yank entire file" })

keymap("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "No Highlight" })
keymap("n", "<leader>w", "<cmd>w!<CR>", { desc = "Save" })
keymap("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit" })
keymap("n", "<leader>e", "<cmd>Explore<CR>", { desc = "Explorer" })
keymap("n", "<leader>u", function()
	vim.cmd.packadd("nvim.undotree")
	vim.cmd.Undotree()
end, { desc = "Undotree toggle" })

keymap("n", "s", "<Nop>", { noremap = true, silent = true })
