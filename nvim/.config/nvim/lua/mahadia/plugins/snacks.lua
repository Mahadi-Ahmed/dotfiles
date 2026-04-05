local setup, snacks = pcall(require, "snacks")
if not setup then
  return
end

-- Initialize snacks with configuration
snacks.setup({
  bigfile = { enabled = true },
  dashboard = require('mahadia.plugins.snacks.dashboard'),
  indent = { enabled = false },
  input = { enabled = true },
  notifier = {
    enabled = true,
    timeout = 3000,
  },
  picker = {
    enabled = true,
    sources = {
      recent = {
        filter = { cwd = true },
      },
    },
    -- Increase timeout for LSP operations in large monorepos
    win = {
      input = {
        keys = {
          -- Add escape to close picker
          ["<Esc>"] = "close",
        },
      },
    },
    -- Configure formatters with better performance for large result sets
    formatters = {
      file = {
        filename_first = true,
      },
    },
    -- Previewers configuration
    previewers = {
      -- Disable preview for better performance if needed
      -- enabled = false,
    },
  },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = false },
  statuscolumn = { enabled = true },
  styles = {
    notification = {}
  },
  image = { enabled = true },
})

-- Define keymaps after ensuring snacks is loaded

-- Set up autocommand to configure keymaps after VeryLazy event
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()

    -- Set up toggles
    snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>ts")
    snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>tw")
    snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>tL")
    snacks.toggle.diagnostics():map("<leader>tdd")

    snacks.toggle.treesitter():map("<leader>tT")
    snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>tb")
    snacks.toggle.inlay_hints():map("<leader>th")
    snacks.toggle.indent():map("<leader>tg")
    snacks.toggle.dim():map("<leader>tD")
  end,
})
