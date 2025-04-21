return {
	-- dir = "~/personal/command.nvim",
	-- dev = true,
  "vieitesss/command.nvim",
	lazy = false,
  config = true,
	keys = {
			{ "<space>co", ":CommandExecute<cr>" },
			{ "<space>cr", ":CommandRexecute<cr>" },
	},
}
