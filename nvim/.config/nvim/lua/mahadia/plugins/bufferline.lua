local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
	return
end

bufferline.setup({
	options = {
		mode = "buffers",
		right_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
		indicator = {
			icon = "▎", -- this should be omitted if indicator style is not 'icon'
			style = "icon", -- style = 'icon' | 'underline' | 'none',
		},
		buffer_close_icon = "",
		modified_icon = "●",
		close_icon = "",
		left_trunc_marker = "",
		right_trunc_marker = "",
		--- name_formatter can be used to change the buffer's label in the bufferline.
		--- Please note some names can/will break the
		--- bufferline so use this at your discretion knowing that it has
		--- some limitations that will *NOT* be fixed.
		max_name_length = 18,
		max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
		truncate_names = true, -- whether or not tab names should be truncated
		tab_size = 18,
		color_icons = true,
		show_buffer_icons = true, -- disable filetype icons for buffers
		show_buffer_close_icons = false,
		show_close_icon = false,
		show_tab_indicators = true,
		show_duplicate_prefix = true, -- whether to show duplicate buffer prefix
		always_show_bufferline = true,
		separator_style = "thin",
	},
})

vim.opt.showtabline = 0 -- hidden by default; pair mode sets this to 2
