-- Set default height to compilation mode window.
vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*compilation*",
    callback = function()
        local total_lines = vim.api.nvim_list_uis()[1].height
        local new_size = math.floor(total_lines * 0.25)
        vim.cmd("resize " .. new_size)
    end
})

return {
	"ej-shafran/compile-mode.nvim",
	branch = "latest",
	dependencies = "nvim-lua/plenary.nvim",
	lazy = false,
	config = function()
		---@type CompileModeOpts
		vim.g.compile_mode = {
			default_command = "",
		}
	end,
	keys = {
		{ "<space>co", "<cmd>bel Compile<cr>" },
		{ "<space>cr", "<cmd>bel Recompile<cr>" }
	}
}
