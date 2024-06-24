return {
    "nvim-lualine/lualine.nvim",
    event = { "BufNewFile", "BufRead", "BufWritePost" },
    opts = {
        options = {
            -- theme = "gruvbox",
            component_separators = { left = '', right = ''},
            section_separators = { left = '', right = ''},
            theme = "auto",
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff' },
            lualine_c = { 'filename' },
            lualine_x = { 'filetype' },
            lualine_y = { 'progress' },
            lualine_z = { 'location' }
        },
    }
}
