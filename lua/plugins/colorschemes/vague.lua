return {
    priority = 1000,
    lazy = false,
    "vague2k/vague.nvim",
    config = function()
        require("vague").setup({
            transparent = true,
        })
        vim.cmd("colorscheme vague")
    end
}
