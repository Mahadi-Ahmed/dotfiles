local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", "eslint_d", "eslint", stop_after_first = true },
		astro = { "prettierd", "eslint_d", "eslint", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
		vue = { "prettierd", "prettier", stop_after_first = true },
		lua = { "stylua", lsp_format = "fallback" },
		html = { "prettierd", "prettier", stop_after_first = true },
		ruby = function(bufnr)
			local cwd = vim.fn.getcwd()
			if vim.fn.filereadable(cwd .. "/.rubocop.yml") == 1 then
				return { "rubocop", stop_after_first = true }
			end
			return { "rubyfmt" }
		end,
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

	formatters = {
		rubocop = {
			command = "bundle",
			args = { "exec", "rubocop", "--autocorrect", "--stdin", "$FILENAME", "--stderr" },
			require_cwd = true,
		},
		biome = {
			require_cwd = true,
		},
		prettierd = {
			require_cwd = true,
		},
		prettier = {
			require_cwd = true,
		},
		eslint_d = {
			require_cwd = true,
		},
		eslint = {
			require_cwd = true,
		},
		-- conform's range end is inclusive but stylua's --range-end is exclusive,
		-- so the last char (e.g. the closing `)`) falls outside and stylua skips the statement
		stylua = {
			range_args = function(_, ctx)
				local start_offset, end_offset = require("conform.util").get_offsets_from_range(ctx.buf, ctx.range)
				return {
					"--search-parent-directories",
					"--stdin-filepath",
					"$FILENAME",
					"--range-start",
					tostring(start_offset),
					"--range-end",
					tostring(end_offset + 1),
					"-",
				}
			end,
		},
	},

	default_format_opts = {
		lsp_format = "fallback",
		timeout_ms = 1000,
	},
})
