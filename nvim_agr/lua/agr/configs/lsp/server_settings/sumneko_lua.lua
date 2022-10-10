return {
	settings = {
		Lua = {
			diagnostics = {
				globals = {
					'bit',
					'vim',
				},
			},
			workspace = {
				library = {
					[vim.fn.expand('$VIMRUNTIME/lua')] = true,
					[vim.fn.stdpath('config') .. '/lua'] = true,
				},
			},
		},
	},
}

