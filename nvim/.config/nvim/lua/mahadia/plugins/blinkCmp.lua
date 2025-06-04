local setup, blink = pcall(require, "blink.cmp")
if not setup then
	return
end

blink.setup({
	keymap = {
		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<Tab>"] = { "select_next", "fallback" },
		["<S-Tab>"] = { "select_prev", "fallback" },
		["<CR>"] = { "accept", "fallback" },
	},

	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "normal",
	},

	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},

	signature = {
		enabled = true,
		window = {
			border = "single",
			scrollbar = false,
		},
	},

	completion = {
		accept = {
			auto_brackets = {
				enabled = true,
			},
		},
		menu = {
			border = "single",
			draw = {
				treesitter = { "lsp" },
				columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
			},
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
			window = {
				border = "rounded",
				scrollbar = false,
			},
		},
		-- 'prefix' will fuzzy match on the text before the cursor
		-- 'full' will fuzzy match on the text before the cursor + the text after the cursor
		keyword = { range = "prefix" },
	},

	snippets = {
		expand = function(snippet)
			require("luasnip").lsp_expand(snippet)
		end,
		active = function(filter)
			if filter and filter.direction then
				return require("luasnip").jumpable(filter.direction)
			end
			return require("luasnip").in_snippet()
		end,
		jump = function(direction)
			require("luasnip").jump(direction)
		end,
		preset = "luasnip",
	},
})
