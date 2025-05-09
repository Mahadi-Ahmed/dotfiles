local lsp = require('lsp-zero')

lsp.preset("recommended")

lsp.ensure_installed({
  'ts_ls',
  'eslint',
  'lua_ls',
  'volar',
})

-- Fix Undefined global 'vim'
lsp.configure('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      }
    }
  }
})

-- lsp.skip_server_setup({'eslint'})

lsp.configure('eslint', {
  settings = {
    workingDirectory = { mode = 'auto' },
    validate = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue"
    },
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
    experimental = {
      useFlatConfig = false
    },
    codeAction = {
      showDocumentation = {
        enable = true
      }
    }
  },
})

-- Configure TypeScript language server for Vue support
lsp.configure('ts_ls', function()
  local vue_typescript_plugin = require('mason-registry')
      .get_package('vue-language-server')
      :get_install_path()
      .. '/node_modules/@vue/language-server'
      .. '/node_modules/@vue/typescript-plugin'

  return {
    init_options = {
      plugins = {
        {
          name = "@vue/typescript-plugin",
          location = vue_typescript_plugin,
          languages = { 'javascript', 'typescript', 'vue' }
        },
      }
    },
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
      'vue',
    },
  }
end)

lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>lW", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>li","<cmd>Telescope lsp_definitions<cr>", opts)
  vim.keymap.set("n", "<leader>lo", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "<leader>lj", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "<leader>lk", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>la", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>lR", "<cmd>Telescope lsp_references <cr>", opts)
  vim.keymap.set("n", "<leader>lr", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, opts)
end)

lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

lsp.setup()

vim.diagnostic.config({
  virtual_text = true,
})

-- Setup cmp
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
  }),
  --- (Optional) Show source name in completion menu
  -- formatting = cmp_format,
})
-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md
