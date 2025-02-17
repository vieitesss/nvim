return {
    lazy = false,
    priority = 1000,
    'alligator/accent.vim',
    config = function()
        -- vim.g.accent_colour="cyan" -- yellow (default)
        vim.g.accent_no_bg=1
        vim.g.accent_darken=1
        vim.cmd.colorscheme "accent"
    end
}
