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
    vim.keymap.set("n", "gi", function() Snacks.picker.lsp_implementations() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>lW", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>li", function() Snacks.picker.lsp_declarations() end, opts)
    vim.keymap.set("n", "<leader>lo", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<leader>lj", function() vim.diagnostic.jump({ count = 1 }) end, opts)
    vim.keymap.set("n", "<leader>lk", function() vim.diagnostic.jump({ count = -1 }) end, opts)
    vim.keymap.set("n", "<leader>la", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "gr", function()
      Snacks.picker.lsp_references({ includeDeclaration = false })
    end, opts)
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

    if client and client.server_capabilities.codeLensProvider then
      vim.keymap.set("n", "<leader>tc", function()
        local enabled = vim.lsp.codelens.is_enabled({ bufnr = event.buf })
        vim.lsp.codelens.enable(not enabled, { bufnr = event.buf })
      end, { buffer = event.buf, desc = "Toggle code lenses" })
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
    'vue_ls',
    'jsonls',
    'emmet_language_server',
    'cssls',
    'taplo',
    'tsc'
  },
  automatic_installation = false,
  automatic_enable = true,
})


vim.lsp.config('tailwindcss', {
  root_markers = {
    'tailwind.config.js',
    'tailwind.config.cjs',
    'tailwind.config.mjs',
    'tailwind.config.ts',
  },
  settings = {
    tailwindCSS = {
      files = {
        exclude = {
          "**/.git/**",
          "**/node_modules/**",
          "**/dist/**",
          "**/build/**",
          "**/.next/**",
          "**/.turbo/**",
          "**/coverage/**",
          "**/api/**",
        },
      },
      experimental = {
        configFile = {
          ["applications/storybook/tailwind.config.js"] = "applications/storybook/**",
          ["design/ragnar-tailwind-config/tailwind.config.js"] = {
            "applications/**",
            "packages/**",
            "design/**",
          },
        },
      },
    },
  },
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

vim.lsp.config('rubocop', {
  root_markers = { ".rubocop.yml" },
  workspace_required = true,
})

vim.lsp.config('ruby_lsp', {
  capabilities = capabilities,
  filetypes = { "ruby", "eruby" },
  cmd = {
    "bash", "-c",
    'PATH="$(mise where ruby)/bin:$PATH" exec ruby-lsp "$@"', "--"
  },
  init_options = {
    enabledFeatures = {
      codeLens = true,
    },
  },
})
vim.lsp.enable('ruby_lsp')

local function send_test_to_tmux(cmd)
  local test_cmd = cmd.arguments[3]
  if not vim.g.test_tmux_pane then
    vim.ui.input({ prompt = "Tmux pane (e.g. {last}, :.1, test:0): " }, function(pane)
      if pane and pane ~= "" then
        vim.g.test_tmux_pane = pane
        vim.fn.system({ "tmux", "send-keys", "-t", pane, test_cmd, "Enter" })
      end
    end)
  else
    vim.fn.system({ "tmux", "send-keys", "-t", vim.g.test_tmux_pane, test_cmd, "Enter" })
  end
end

vim.lsp.commands["rubyLsp.runTest"] = send_test_to_tmux
vim.lsp.commands["rubyLsp.runTestInTerminal"] = send_test_to_tmux

vim.lsp.config('gopls', {
  capabilities = capabilities,
  filetypes = { 'go' },
  settings = {
    gopls = {
      codelenses = {
        test = true,
        generate = true,
        tidy = true,
        runGovulncheck = true,
      },
    },
  },
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

vim.lsp.config('taplo', {
  capabilities = capabilities,
  filetypes = { 'toml' },
  -- settings = {
  --   evenBetterToml = {
  --     schema = {
  --       enabled = true,
  --       associations = {
  --         ["starship\\.toml$"] = "https://starship.rs/config-schema.json",
  --       },
  --     },
  --   },
  -- },
})

-- /Users/mahadiahmed/.claude-work

vim.lsp.config("jsonls", {
  capabilities = capabilities,
  settings = {
    json = {
      schemas = {
        {
          fileMatch = { "**/.claude/settings.json", "**/.claude-work/settings.json","**/.claude/settings.local.json" },
          url = "https://json.schemastore.org/claude-code-settings.json",
        },
        {
          fileMatch = { "**/.claude/keybindings.json" },
          url = "https://json.schemastore.org/claude-code-keybindings.json",
        },
      },
      validate = { enable = true },
    },
  },
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
