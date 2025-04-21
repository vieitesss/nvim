return {
	-- dir = "~/personal/command.nvim",
	-- dev = true,
  "vieitesss/command.nvim",
	cmd = { "CommandRexecute", "CommandExecute" },
  config = true,
	keys = {
			{ "<space>co", ":CommandExecute<cr>" },
			{ "<space>cr", ":CommandRexecute<cr>" },
	},
}
