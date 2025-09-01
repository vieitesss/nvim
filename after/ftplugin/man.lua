pcall(function() require('zen-mode').open() end)
vim.schedule(
    function()
        vim.cmd.normal({ args = { 'L' }, bang = true })
    end
)
pcall(vim.keymap.del, 'n', 'q', { buffer = true })
vim.keymap.set('n', 'q',
    function()
        pcall(function() require('zen-mode').close() end)
        vim.cmd('quit')
    end, { buffer = true, silent = true }
)
