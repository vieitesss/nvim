return {
    "nvim-lualine/lualine.nvim",
    event = "BufRead",
    enabled = false,
    opts = {
        options = {
            theme = "auto",
            component_separators = { left = '󰿟', right = '󰿟' },
            section_separators = { left = '󰿟', right = '󰿟' },
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = {
                {
                    'branch',
                    icon = '',
                    fmt = shorten_branch,
                }, 'diff' },
            lualine_c = { { 'filename', path = 4 } },
            lualine_x = { 'filetype' },
            lualine_y = { 'progress' },
            lualine_z = { 'location' }
        },
    }
}
