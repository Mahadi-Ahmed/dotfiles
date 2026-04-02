local status, treesitter = pcall(require, "nvim-treesitter")
if not status then
  return
end

treesitter.setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Install parsers (replaces ensure_installed)
treesitter.install({
  "json",
  "javascript",
  "typescript",
  "tsx",
  "yaml",
  "html",
  "css",
  "scss",
  "markdown",
  "bash",
  "lua",
  "vim",
  "dockerfile",
  "gitignore",
  "vue",
  "python",
  "regex",
  "ruby",
})

-- Enable treesitter highlighting for filetypes with installed parsers.
-- Neovim 0.12 only auto-enables for lua, markdown, help, query.
-- Replaces `highlight = { enable = true }` from the old master branch.
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
