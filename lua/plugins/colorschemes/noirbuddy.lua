local main_color = '#A6C972'
return {
    'jesseleite/nvim-noirbuddy',
    dependencies = 'tjdevries/colorbuddy.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        require("noirbuddy").setup({
            colors = {
                primary = main_color,
                diagnostic_info = main_color,
                diagnostic_hint = main_color
            }
        })
    end
}
