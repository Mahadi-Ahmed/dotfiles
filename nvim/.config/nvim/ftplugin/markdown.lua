local set = vim.opt_local

-- Visual wrapping for better reading experience (doesn't modify file)
set.wrap = true              -- Enable visual line wrapping
set.linebreak = true         -- Break at word boundaries, not mid-word
set.breakindent = true       -- Wrapped lines visually align with the start of the line
set.showbreak = "↪ "         -- Show indicator for wrapped lines

-- Set soft wrap column (visual guide at 120 chars)
set.colorcolumn = "100"      -- Visual guide line at column 100

-- Disable hard wrapping (we want visual wrapping only)
set.textwidth = 0            -- Don't auto-insert newlines

-- Enable spell checking
set.spell = true

-- Make j/k move by visual lines, not file lines (useful with wrap)
vim.keymap.set('n', 'j', 'gj', { buffer = true, silent = true })
vim.keymap.set('n', 'k', 'gk', { buffer = true, silent = true })
