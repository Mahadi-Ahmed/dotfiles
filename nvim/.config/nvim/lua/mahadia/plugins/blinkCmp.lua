local setup, blink = pcall(require, "blink.cmp")
if not setup then
	return
end

blink.setup({
	keymap = { preset = "default" },

	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},

	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
		-- optionally disable cmdline completions
		-- cmdline = {},
	},

	signature = {
		enabled = true,
		window = {
			border = "rounded",
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
			border = "rounded",
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
		-- NEW: Set the preset to luasnip
		preset = "luasnip",
	},

	-- experimental auto-completion support
	-- completion = {
	--   trigger = { show_on_insert_on_trigger_character = false }
	-- },
})
