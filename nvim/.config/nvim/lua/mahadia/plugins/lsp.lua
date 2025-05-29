local mason = require('mason')
local lspconfig = require('lspconfig')
local mason_lspconfig = require('mason-lspconfig')

mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

mason_lspconfig.setup({
  ensure_installed = {
    'ts_ls',
    'eslint',
    'lua_ls',
    'gopls',
  },
  automatic_installation = true,
  automatic_setup = false,
})

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }
  vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<cr>", opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>lW", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>li", "<cmd>Telescope lsp_definitions<cr>", opts)
  vim.keymap.set("n", "<leader>lo", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "<leader>lj", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "<leader>lk", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>la", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references <cr>", opts)
  vim.keymap.set("n", "<leader>lr", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, opts)
end


-- Set up LSP capabilities for nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Configure Lua
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Configure TypeScript/JavaScript
lspconfig.ts_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Configure Go
lspconfig.gopls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Configure ESLint
lspconfig.eslint.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    workingDirectory = { mode = 'auto' },
    validate = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue"
    },
    experimental = {
      useFlatConfig = false
    },
    codeAction = {
      showDocumentation = {
        enable = true
      }
    }
  },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' }
})

-- Set up nvim-cmp
local cmp = require('cmp')
local luasnip = require('luasnip')

-- Load snippets
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },


  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),

    -- Tab completion
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),

  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
})

vim.diagnostic.config({
  virtual_text = true,
})
