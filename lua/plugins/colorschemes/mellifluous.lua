return {
    "ramojus/mellifluous.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("mellifluous").setup({
            colorset = 'kanagawa_dragon',
            mellifluous = {
                bg_contrast = 'hard',
            },
            -- transparent_background = {
            --     enabled = true
            -- }
        })
        vim.cmd([[colorscheme mellifluous]])
    end
}
