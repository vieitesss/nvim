return {
    lazy = false,
    priority = 1000,
    'shaunsingh/nord.nvim',
    config = function()
        vim.g.nord_bold = false
        vim.g.nord_italic = false
        require('nord').set()

        vim.cmd.colorscheme "nord"
    end
}
