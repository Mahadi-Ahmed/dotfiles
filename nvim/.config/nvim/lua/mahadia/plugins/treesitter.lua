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
