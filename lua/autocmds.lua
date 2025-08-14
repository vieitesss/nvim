local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight yanked text
local highlight_group = augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({ timeout = 170 })
    end,
    group = highlight_group,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.keymap.set('n', '<C-c>', '<cmd>bd<CR>', { buffer = true, silent = true })
        vim.keymap.set('n', '<Tab>', 'mf', { buffer = true, remap = true, silent = true })
        vim.keymap.set('n', '<S-Tab>', 'mF', { buffer = true, remap = true, silent = true })
        vim.keymap.set('n', '%', function()
            local dir = vim.b.netrw_curdir or vim.fn.expand('%:p:h')
            vim.ui.input({ prompt = 'Enter filename: ' }, function(input)
                if input and input ~= '' then
                    local filepath = dir .. '/' .. input
                    vim.cmd('!touch ' .. vim.fn.shellescape(filepath))
                    vim.api.nvim_feedkeys('<C-l>', 'n', false)
                end
            end)
        end, { buffer = true, silent = true })
    end
})
