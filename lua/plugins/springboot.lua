return {
    'niT-Tin/springboot-start.nvim',
    ft = "java",
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
        'MunifTanjim/nui.nvim',
    },
    config = function()
        require('springboot-start').setup({
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        })
    end
}
