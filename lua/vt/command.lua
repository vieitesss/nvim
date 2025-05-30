return {
    dir = "~/personal/command.nvim",
    dev = true,
    -- "vieitesss/command.nvim",
    cmd = { "CommandRexecute", "CommandExecute" },
    opts = true,
    keys = {
        { "<space>co", ":CommandExecute<cr>" },
        { "<space>cr", ":CommandRexecute<cr>" },
    },
}
