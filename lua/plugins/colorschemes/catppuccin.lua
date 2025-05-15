return {
    lazy = false,
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            no_italic = true,
            transparent_background = false,
            color_overrides = {
                mocha = {
                    lavender = "#cdd6f4"
                },
            }
        })
        vim.cmd.colorscheme "catppuccin"
    end
}
