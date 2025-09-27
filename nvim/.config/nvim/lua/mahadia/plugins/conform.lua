local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		vue = { "prettierd", "prettier", stop_after_first = true },
		lua = { "stylua", lsp_format = "fallback" },
		html = { "prettierd", "prettier", stop_after_first = true },
		ruby = { "rubyfmt", stop_after_first = true },
		yaml = function(bufnr)
			local filename = vim.api.nvim_buf_get_name(bufnr)
			if filename:match("%.github/workflows/") then
				return { lsp_format = "fallback" }
			else
				return { "prettierd", "prettier", lsp_format = "fallback", stop_after_first = true }
			end
		end,

		go = { lsp_format = "fallback" },
	},

	default_format_opts = {
		lsp_format = "fallback",
		timeout_ms = 1000,
	},
})
