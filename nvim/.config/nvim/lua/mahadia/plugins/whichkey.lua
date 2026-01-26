local wk = require("which-key")

-- Setup options
local setup = {
  preset= "modern",
  plugins = {
    marks = true,
    registers = true,
    spelling = {
      enabled = true,
      suggestions = 20,
    },
    presets = {
      operators = false,
      motions = true,
      text_objects = true,
      windows = true,
      nav = true,
      z = true,
      g = true,
    },
  },
  sort = { "order"},
  icons = {
    breadcrumb = "»",
    separator = "➜",
    group = "+",
  },
  -- window = {
  --   border = "rounded",
  --   position = "bottom",
  --   margin = { 1, 0, 1, 0 },
  --   padding = { 2, 2, 2, 2 },
  --   winblend = 0,
  -- },
  layout = {
    height = { min = 4, max = 25 },
    width = { min = 20, max = 50 },
    spacing = 4,
    align = "center",
  },
  show_help = true,
}

wk.setup(setup)

-- Mappings
wk.add({
  { "<leader><space>", "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<cr>" , desc = "find buffers" }, -- NOTE: Prefer telescope, snacks does not handle last_used well
  { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },

  { "<leader>h", "<cmd>nohlsearch<CR>", desc = "No Highlight" },
  { "<leader>q", "<cmd>qa<CR>", desc = "Quit" },
  { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Undotree toggle" },
  { "<leader>w", "<cmd>w!<CR>", desc = "Save" },
  { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer" },

  { "<leader>b", group = "Buffers" },
  { "<leader>bm", "<cmd>MaximizerToggle<cr>", desc = "Maximize split toggle" },
  { "<leader>bd", "<cmd>bd<cr>", desc = "Delete buffer" },

  {
    "<leader>f",
    function()
	Snacks.picker.files({
		hidden = true,
		follow = true,
	})
    end,
    desc = "Find File"
  },

  { "<leader>g", group = "Git" },
  { "<leader>gc", "<cmd>lua Snacks.picker.git_log_file()<cr>", desc = "Checkout commit(for current file)" },
  {
    "<leader>gC",
    function()
	Snacks.picker.git_log({
		confirm = function(picker, item)
			picker:close()
			if item then
				-- Extract commit hash from the selected item
				local commit = item.commit or item.hash or item[1]
				if not commit then
					vim.notify("Could not determine commit hash", vim.log.levels.ERROR)
					return
				end

				-- Get list of files changed in this commit
				local cmd = string.format("git diff-tree --no-commit-id --name-only -r %s", commit)
				local handle = io.popen(cmd)
				if not handle then
					vim.notify("Failed to get changed files", vim.log.levels.ERROR)
					return
				end

				local files = {}
				for file in handle:lines() do
					if file ~= "" then
						table.insert(files, file)
					end
				end
				handle:close()

				if #files == 0 then
					vim.notify("No files changed in commit " .. commit:sub(1, 7), vim.log.levels.WARN)
					return
				end

				-- Open each file in a buffer (only if it exists in working tree)
				local opened = 0
				for _, file in ipairs(files) do
					if vim.fn.filereadable(file) == 1 then
						vim.cmd("edit " .. vim.fn.fnameescape(file))
						opened = opened + 1
					end
				end

				vim.notify(
					string.format("Opened %d/%d files from commit %s", opened, #files, commit:sub(1, 7)),
					vim.log.levels.INFO
				)
			end
		end,
	})
    end,
    desc = "Open files from commit"
  },
  { "<leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", desc = "Reset Buffer" },
  { "<leader>gg", "<cmd>lua _lazygit_toggle()<CR>", desc = "Lazygit" },
  { "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk({navigation_message = false})<cr>", desc = "Next Hunk" },
  { "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk({navigation_message = false})<cr>", desc = "Prev Hunk" },
  { "<leader>gl", "<cmd>lua require 'gitsigns'.blame_line()<cr>", desc = "Blame" },
  { "<leader>go", "<cmd>Telescope git_status<cr>", desc = "Open changed file" },
  { "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk_inline()<cr>", desc = "Preview Hunk" },
  { "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", desc = "Reset Hunk" },
  { "<leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", desc = "Stage Hunk" },
  { "<leader>gu", "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", desc = "Undo Stage Hunk" },

  { "<leader>gd", group = "Diff" },
  { "<leader>gdd", "<cmd>CodeDiff file HEAD<cr>", desc = "Diff file vs HEAD" },
  { "<leader>gdD", "<cmd>CodeDiff<cr>", desc = "Diff explorer (all changes)" },
  {
    "<leader>gdb",
    function()
      local branch = vim.fn.input("Compare with branch/commit: ", "main")
      if branch ~= "" then
        vim.cmd("CodeDiff file " .. branch)
      end
    end,
    desc = "Diff file vs branch/commit"
  },
  {
    "<leader>gdm",
    "<cmd>CodeDiff file main<cr>",
    desc = "Diff file vs main branch"
  },
  {
    "<leader>gds",
    "<cmd>CodeDiff file HEAD~1<cr>",
    desc = "Diff file vs previous commit"
  },
  {
    "<leader>gdc",
    function()
      local commit = vim.fn.input("Compare with commit: ")
      if commit ~= "" then
        vim.cmd("CodeDiff file " .. commit)
      end
    end,
    desc = "Diff file vs specific commit"
  },
  {
    "<leader>gdr",
    function()
      local rev1 = vim.fn.input("First revision (e.g., main): ")
      if rev1 == "" then return end
      local rev2 = vim.fn.input("Second revision (e.g., HEAD): ")
      if rev2 == "" then return end
      vim.cmd("CodeDiff " .. rev1 .. " " .. rev2)
    end,
    desc = "Diff explorer (two branches/commits)"
  },
  {
    "<leader>gdf",
    function()
      local current_file = vim.api.nvim_buf_get_name(0)
      if current_file == "" then
        vim.notify("No file in current buffer", vim.log.levels.WARN)
        return
      end

      -- Use Snacks picker to select a file to compare against
      Snacks.picker.files({
        hidden = true,
        follow = true,
        confirm = function(picker, item)
          picker:close()
          if item then
            local compare_file = item.file or item.path or item[1]
            vim.cmd("CodeDiff file " .. vim.fn.fnameescape(current_file) .. " " .. vim.fn.fnameescape(compare_file))
            vim.notify("Diffing: " .. vim.fn.fnamemodify(current_file, ":t") .. " ↔ " .. vim.fn.fnamemodify(compare_file, ":t"))
          end
        end,
      })
    end,
    desc = "Diff current file vs another file"
  },

  { "<leader>gh", group = "GitHub" },
  { "<leader>ghp", "<cmd>lua Snacks.picker.gh_pr()<cr>", desc = "List open PRs" },
  { "<leader>ghm", "<cmd>lua Snacks.picker.gh_pr({ author = '@me' })<cr>", desc = "My PRs" },
  { "<leader>ghr", "<cmd>lua Snacks.picker.gh_pr({ review = 'requested' })<cr>", desc = "Review requests" },
  { "<leader>ghA", "<cmd>lua Snacks.picker.gh_pr({ assignee = '@me' })<cr>", desc = "Assigned to me" },
  { "<leader>ghl", "<cmd>lua Snacks.picker.gh_pr({ label = 'Team: Payments Team' })<cr>", desc = "Payments Team PRs" },
  { "<leader>gho", "<cmd>lua Snacks.gitbrowse.open()<cr>", desc = "open github web" },

  { "<leader>j", group = "Harpoon" },
  { "<leader>ja", "<cmd>lua require('harpoon'):list():select(4)<cr>", desc = "Index 4" },
  { "<leader>jd", "<cmd>lua require('harpoon'):list():select(2)<cr>", desc = "Index 2" },
  { "<leader>jf", "<cmd>lua require('harpoon'):list():select(1)<cr>", desc = "Index 1" },
  { "<leader>jg", "<cmd>lua require('harpoon'):list():select(5)<cr>", desc = "Index 5" },
  { "<leader>jh", "<cmd>lua require('harpoon'):list():select(6)<cr>", desc = "Index 6" },
  { "<leader>jp", "<cmd>lua require('harpoon'):list():prev()<cr>", desc = "Previous mark" },
  { "<leader>jn", "<cmd>lua require('harpoon'):list():next()<cr>", desc = "Next mark" },
  { "<leader>ji", "<cmd>lua require('harpoon'):list():add()<cr>", desc = "Add file" },
  { "<leader>jm", "<cmd>lua require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())<cr>", desc = "Toggle menu" },
  { "<leader>js", "<cmd>lua require('harpoon'):list():select(3)<cr>", desc = "Index 3" },
  -- { "<leader>jr", "<cmd>lua _G.harpoon_telescope(require('harpoon'):list())<cr>", desc = "Telescope Harpoon" },

  { "<leader>l", group = "lsp zero" },
  { "<leader>lW", desc = "workspace symbols" },
  { "<leader>la", desc = "code action" },
  { "<leader>lf", desc = "format" },
  { "<leader>li", desc = "declarations" },
  { "<leader>lj", desc = "next diagnostic" },
  { "<leader>lk", desc = "previous diagnostic" },
  { "<leader>lo", desc = "open float" },
  { "<leader>lr", desc = "rename" },
  { "<leader>lw", "<cmd>Telescope diagnostics<cr>", desc = "diagnostics" },
  { "<leader>lm", "<cmd>%!jq . <cr>", desc = "Format json" },

  { "<leader>m", group = "Session" },
  { "<leader>mr", "<cmd>AutoSession restore<CR>",group = "Restore session for cwd" },
  { "<leader>ms", "<cmd>AutoSession save<CR>",group = "Save session for auto session root dir" },

  { "<leader>s", group = "Search" },
  { "<leader>s:", "<cmd>Telescope commands<cr>", desc = "Commands" },
  { "<leader>sR", "<cmd>Telescope registers<cr>", desc = "Registers" },
  { "<leader>sl", "<cmd>Telescope current_buffer_fuzzy_find theme=ivy<cr>", desc = "Current buffer fuzzy find" },
  { "<leader>sc", "<cmd>Telescope grep_string<cr>", desc = "Find Text under cursor" },
  { "<leader>sf", "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>", desc = "Find files" },
  { "<leader>sh", "<cmd>lua Snacks.picker.pickers()<cr>", desc = "Find pickers" },
  { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
  { "<leader>st", "<cmd>Telescope live_grep<cr>", desc = "Find Text" },
  { "<leader>sT", "<cmd>TodoTelescope<cr>", desc = "Find ToDo" },
  { "<leader>ss", "<cmd>Telescope spell_suggest theme=cursor<cr>", desc = "Spelling" },
  { "<leader>sn", "<cmd>NoiceAll<cr>", desc = "open Notification in window" },
  { "<leader>su", "<cmd>Telescope undo<cr>", desc = "Undo History" },

  { "<leader>t", group = "Toggle\'s" },
  { "<leader>tt", "<cmd>ColorizerToggle<CR>", desc = "Colorizer toggle" },
  { "<leader>tl", "<cmd>LineNumberToggle<CR>", desc = "Line number toggle" },
})
