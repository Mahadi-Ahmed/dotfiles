local mason = require('mason')
local lspconfig = require('lspconfig')
local mason_lspconfig = require('mason-lspconfig')
print('hejhej')
print("LSP config file loaded at:", os.date())

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('mahadia-lsp-attach', { clear = true }),
  callback = function(event)
    print('LSP attached:', vim.lsp.get_client_by_id(event.data.client_id).name, 'to buffer:', event.buf)

    local opts = { buffer = event.buf }
    vim.keymap.set({ "n", "v" }, "<leader>lf", function() vim.lsp.buf.format({}) end, opts)
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
  end,
})

mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

mason_lspconfig.setup({
  ensure_installed = {
    'ts_ls',
    'eslint',
    'lua_ls',
    'gopls',
  },
  automatic_installation = false,
  handlers = {
    -- Default handler for mason-configured servers
    function(server_name)
      print("Handler called for server:", server_name)
      print("About to call lspconfig setup for:", server_name)
      lspconfig[server_name].setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
      print("Finished setup for:", server_name)
    end,

    ["lua_ls"] = function()
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end,

    ["ts_ls"] = function()
      lspconfig.ts_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end,

    ["gopls"] = function()
      lspconfig.gopls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end,


    ["eslint"] = function()
      lspconfig.eslint.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        -- settings = {
        --   workingDirectory = { mode = 'auto' },
        --   validate = {
        --     "javascript",
        --     "javascriptreact",
        --     "typescript",
        --     "typescriptreact",
        --     "vue"
        --   },
        --   experimental = {
        --     useFlatConfig = false
        --   },
        --   codeAction = {
        --     showDocumentation = {
        --       enable = true
        --     }
        --   }
        -- },
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' }
      })
    end

  }
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
