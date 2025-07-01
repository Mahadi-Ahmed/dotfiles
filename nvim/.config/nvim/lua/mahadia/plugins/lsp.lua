local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('mahadia-lsp-attach', { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf }
    vim.keymap.set({ "n", "v" }, "<leader>lf", function()
        require("conform").format({ async = false, lsp_format = "fallback" })
    end, opts)
    vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>lW", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>li", function() Snacks.picker.lsp_declarations() end, opts)
    vim.keymap.set("n", "<leader>lo", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<leader>lj", function() vim.diagnostic.jump({ count = 1 }) end, opts)
    vim.keymap.set("n", "<leader>lk", function() vim.diagnostic.jump({ count = -1 }) end, opts)
    vim.keymap.set("n", "<leader>la", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "gr", function() Snacks.picker.lsp_references() end, opts)
    vim.keymap.set("n", "<leader>lr", function() vim.lsp.buf.rename() end, opts)

    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

    -- Enable inlay hints if the server supports them
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })

      vim.keymap.set("n", "<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
      end, { buffer = event.buf, desc = "Toggle inlay hints" })
    end
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

local capabilities = require('blink.cmp').get_lsp_capabilities()

mason_lspconfig.setup({
  ensure_installed = {
    'eslint',
    'lua_ls',
    'gopls',
    'vtsls',
    'vue_ls',
    'jsonls',
    'emmet_language_server',
    'cssls'
  },
  automatic_installation = false,
  automatic_enable = true,
})

vim.lsp.config('vtsls', {
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
  capabilities = capabilities,
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {}
      },
      autoUseWorkspaceTsdk = true,
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
    typescript = {
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        completeFunctionCalls = true,
      },
      preferences = {
        importModuleSpecifier = 'non-relative',
      },
      inlayHints = {
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = false },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        completeFunctionCalls = true,
      },
    }
  },
  before_init = function(_, config)
    table.insert(config.settings.vtsls.tsserver.globalPlugins, {
      name = '@vue/typescript-plugin',
      location = vim.fn.expand('$MASON/packages/vue-language-server/node_modules/@vue/language-server'),
      languages = { 'vue' },
      configNamespace = 'typescript',
      enableForWorkspaceTypeScriptVersions = true,
    })
  end,
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
})

vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,
      },
      completion = {
        callSnippet = 'Replace',
      },
      telemetry = {
        enable = false,
      },
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
})

vim.lsp.config('gopls', {
  capabilities = capabilities,
})

vim.lsp.config('eslint', {
  capabilities = capabilities,
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' }
})

vim.lsp.config('yamlls', {
  capabilities = capabilities,
  settings = {
    yaml = {
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
        ["https://json.schemastore.org/github-action.json"] = "/action.{yml,yaml}",
      },
      validate = true,
      completion = true,
      hover = true,
      format = {
        enable = true,
      },
    },
    redhat = {
      telemetry = {
        enabled = false,
      },
    },
  },
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = true
  end,
})

Icons = require('mahadia.plugins.icons')

vim.diagnostic.config({
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = Icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = Icons.diagnostics.Warning,
      [vim.diagnostic.severity.INFO] = Icons.diagnostics.Information,
      [vim.diagnostic.severity.HINT] = Icons.diagnostics.Hint,
    },
  },
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      return diagnostic.message
    end,
  },
})

vim.keymap.set('n', '<leader>tdt', function()
  local new_config = not vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = new_config })
end, { desc = 'Toggle diagnostic virtual_text' })
