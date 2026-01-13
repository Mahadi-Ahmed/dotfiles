-- Shorten function name
local keymap = vim.keymap.set
-- Silent keymap option
local opts = { silent = false }

-- NOTE: look for more keymaps in whichkey.lua

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --

-- Dont save x in registeter
--keymap("n", "x", '"_x')

-- Resize with arrows
keymap("n", "<A-Up>", ":resize -2<CR>", opts)
keymap("n", "<A-Down>", ":resize +2<CR>", opts)
keymap("n", "<A-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<A-Right>", ":vertical resize +2<CR>", opts)

-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts)

keymap("n", "<C-d>", "<C-d>", opts)
keymap("n", "<C-u>", "<C-u>", opts)
-- keymap("n", "k", "kzz")
-- keymap("n", "j", "jzz")

-- visual block mode
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

keymap("x", "<leader>p", [["_dP"]])
-- Use <Space> directly to avoid timeout conflict with <leader>yf
keymap({"n", "v"}, "<Space>y", [["+y]])
keymap("n", "<Space>Y", [["+Y]])
keymap({"n", "v"}, "<leader>p", [["+p"]])
keymap({"n", "v"}, "<leader>P", [["+P"]])
keymap("n", "<leader>ya", "gg\"*yG<C-o>", { desc = "Yank entire file", silent = false })

-- Yank file path with line number reference
local function get_relative_path()
	-- Try to get path relative to git root first
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if vim.v.shell_error == 0 and git_root then
		local full_path = vim.fn.expand("%:p")
		return full_path:gsub("^" .. vim.pesc(git_root) .. "/", "")
	end
	-- Fallback to cwd-relative path
	return vim.fn.expand("%:.")
end

local function yank_file_reference()
	local path = get_relative_path() .. ":" .. vim.fn.line(".")
	vim.fn.setreg("+", path)
	vim.notify("Yanked: " .. path, vim.log.levels.INFO)
end

local function yank_file_reference_range()
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	local lines = { start_line, end_line }
	table.sort(lines)

	local path = get_relative_path() .. ":" .. table.concat(lines, "-")
	vim.fn.setreg("+", path)
	vim.notify("Yanked: " .. path, vim.log.levels.INFO)

	-- Exit visual mode
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end

keymap("n", "<leader>yf", yank_file_reference, { desc = "Yank file:line reference", silent = true })
keymap("v", "<leader>yf", yank_file_reference_range, { desc = "Yank file:line-line reference", silent = true })

keymap('n', 's', '<Nop>', { noremap = true, silent = true })
