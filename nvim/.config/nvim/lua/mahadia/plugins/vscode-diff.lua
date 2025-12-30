local setup, vscode_diff = pcall(require, "vscode-diff")
if not setup then
  return
end

vscode_diff.setup({
  -- Highlight configuration - uses your colorscheme's diff colors
  highlights = {
    -- Line-level: accepts highlight group names or hex colors
    line_insert = "DiffAdd",      -- Line-level insertions (green background)
    line_delete = "DiffDelete",   -- Line-level deletions (red background)

    -- Character-level: auto-derived from line colors with brightness adjustment
    -- nil = auto-detect based on background (1.4x brighter for dark, 0.92x darker for light)
    char_insert = nil,            -- Character-level insertions (darker green)
    char_delete = nil,            -- Character-level deletions (darker red)

    -- Brightness multiplier for character highlights (nil = auto-detect)
    char_brightness = nil,        -- Auto-adjust based on your colorscheme
  },

  -- Diff view behavior
  diff = {
    disable_inlay_hints = true,         -- Disable inlay hints in diff windows for cleaner view
    max_computation_time_ms = 5000,     -- Maximum time for diff computation (VSCode default)
  },

  -- Explorer panel configuration (when using CodeDiff without arguments)
  explorer = {
    position = "left",              -- "left" or "bottom"
    width = 45,                     -- Width when position is "left" (columns)
    height = 15,                    -- Height when position is "bottom" (lines)
    indent_markers = true,          -- Show tree indent markers (│, ├, └)
    icons = {
      folder_closed = "",          -- Nerd Font folder icon
      folder_open = "",            -- Nerd Font folder-open icon
    },
    view_mode = "tree",             -- "list" or "tree" - tree shows folder structure
    file_filter = {
      ignore = {
        "*.lock",                   -- Ignore lock files
        "lazy-lock.json",           -- Ignore lazy.nvim lock file
        "node_modules/*",           -- Ignore node_modules
        "dist/*",                   -- Ignore build directories
        "build/*",
        ".git/*",
      },
    },
  },

  -- Keymaps in diff view (when comparing files side-by-side)
  keymaps = {
    view = {
      quit = "q",                       -- Close diff tab
      toggle_explorer = "<leader>b",    -- Toggle explorer visibility (in explorer mode)
      next_hunk = "]c",                 -- Jump to next change (vim-style navigation)
      prev_hunk = "[c",                 -- Jump to previous change
      next_file = "]f",                 -- Next file in explorer mode
      prev_file = "[f",                 -- Previous file in explorer mode
      diff_get = "do",                  -- Get change from other buffer (like vimdiff)
      diff_put = "dp",                  -- Put change to other buffer (like vimdiff)
    },
    explorer = {
      select = "<CR>",                  -- Open diff for selected file
      hover = "K",                      -- Show file diff preview popup
      refresh = "R",                    -- Refresh git status
      toggle_view_mode = "i",           -- Toggle between 'list' and 'tree' views
    },
  },
})
