--[[
 THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
 `lvim` is the global options object
]]
-- vim options
vim.opt.shiftwidth                                  = 2
vim.opt.tabstop                                     = 2
vim.opt.relativenumber                              = true
vim.opt.updatetime                                  = 300
vim.opt.timeoutlen                                  = 350
vim.g["sneak#label"]                                = true
vim.opt.termguicolors                               = true -- set term gui colors (most terminals support this)

-- general
lvim.log.level                                      = "info"
lvim.format_on_save                                 = {
  enabled = true,
  pattern = "*.lua",
  timeout = 1000,
}

-- lvim.builtin.lualine.style = "lvim"
lvim.builtin.indentlines                            = "disable"
lvim.transparent_window                             = true
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
lvim.leader                                         = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"]                      = ":w<cr>"

-- lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
-- lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"

-- -- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["W"] = { "<cmd>noautocmd w<cr>", "Save without formatting" }
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }

lvim.builtin.which_key.mappings["j"]                = {
  name = "Harpoon",
  m = { ':lua require("harpoon.ui").toggle_quick_menu()<cr>', 'toggle menu' },
  i = { '<cmd>lua require("harpoon.mark").add_file()<cr>', 'add file' },
  f = { ':lua require("harpoon.ui").nav_file(1)<cr>', 'Index 1' },
  d = { ':lua require("harpoon.ui").nav_file(2)<cr>', 'Index 2' },
  s = { ':lua require("harpoon.ui").nav_file(3)<cr>', 'Index 3' },
  a = { ':lua require("harpoon.ui").nav_file(4)<cr>', 'Index 4' },
  g = { ':lua require("harpoon.ui").nav_file(5)<cr>', 'Index 5' },
  r = { ':Telescope harpoon marks<cr>', 'Telescope Harpoon' }
}

-- UndoTree --
lvim.builtin.which_key.mappings["u"]                = {
  name = "UndoTree",
  f = { ':UndotreeToggle<cr>', 'toggle menu' }
}

-- add your own keymapping
lvim.builtin.which_key.mappings["bm"]               = {
  ":MaximizerToggle<cr>", "maximize split toggle"
}
lvim.keys.normal_mode["<C-s>"]                      = ":w<cr>"

-- -- Change theme settings
-- lvim.colorscheme = "lunar"
lvim.colorscheme                                    = "rose-pine"

lvim.builtin.alpha.active                           = true
lvim.builtin.alpha.mode                             = "dashboard"
lvim.builtin.terminal.active                        = true
lvim.builtin.nvimtree.setup.view.side               = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- Automatically install missing parsers when entering buffer
lvim.builtin.treesitter.auto_install                = true

-- lvim.builtin.treesitter.ignore_install = { "haskell" }

-- -- always installed on startup, useful for parsers without a strict filetype
-- lvim.builtin.treesitter.ensure_installed = { "comment", "markdown_inline", "regex" }

-- -- generic LSP settings <https://www.lunarvim.org/docs/languages#lsp-support>

-- --- disable automatic installation of servers
-- lvim.lsp.installer.setup.automatic_installation = false

-- ---configure a server manually. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---see the full default list `:lua =lvim.lsp.automatic_configuration.skipped_servers`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- linters and formatters <https://www.lunarvim.org/docs/languages#lintingformatting>
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--   { command = "stylua" },
--   {
--     command = "prettier",
--     extra_args = { "--print-width", "100" },
--     filetypes = { "typescript", "typescriptreact" },
--   },
-- }
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
--   {
--     command = "shellcheck",
--     args = { "--severity", "warning" },
--   },
-- }

-- -- Additional Plugins <https://www.lunarvim.org/docs/plugins#user-plugins>
lvim.plugins                                        = {
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  { "rose-pine/neovim" },
  {
    "folke/todo-comments.nvim",
    event = "BufRead",
    config = function()
      require("todo-comments").setup()
    end,
  },
  {
    "ThePrimeagen/harpoon",
    config = function()
      require("harpoon").setup({
        width = vim.api.nvim_win_get_width(0) - 60,
      })
    end,
  },
  { "kshenoy/vim-signature" },
  { "szw/vim-maximizer" }, -- maximized and restore current window
  { "tpope/vim-surround" },
  { "mbbill/undotree" },
  { "justinmk/vim-sneak" }, {
  "windwp/nvim-ts-autotag",
  config = function()
    require("nvim-ts-autotag").setup()
  end,
},

  { 'dstein64/vim-startuptime' }
}

-- -- Autocommands (`:help autocmd`) <https://neovim.io/doc/user/autocmd.html>
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })
