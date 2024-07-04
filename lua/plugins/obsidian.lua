return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    event = {
        "BufReadPre" .. vim.fn.expand "~" .. "/obsidian/**.md",
        "BufNewFile" .. vim.fn.expand "~" .. "/obsidian/**.md",
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        workspaces = {
            {
                name = "personal",
                path = "~/obsidian",
            }
        }
    }
}
