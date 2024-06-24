return {
    lazy = false,
    priority = 1000,
    'alligator/accent.vim',
    config = function()
        vim.g.accent_colour="green"
        vim.g.accent_no_bg=1

        vim.cmd.colorscheme "accent"
    end
}
