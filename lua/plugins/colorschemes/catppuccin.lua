return {
    lazy = false,
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "frappe",
            no_italic = true,
            transparent_background = true,
        })
        vim.cmd.colorscheme "catppuccin"
    end
}
