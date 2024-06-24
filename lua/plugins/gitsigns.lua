return {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    config = function()
        local gs = require('gitsigns')
        gs.setup({
            signs = {
                add = { text = "+" },
                change = { text = "" }
            }
        })

        vim.keymap.set('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, { noremap = true, silent = true })

        vim.keymap.set('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, { noremap = true, silent = true })

        vim.keymap.set('n', '<leader>hs', gs.stage_hunk)
        vim.keymap.set('n', '<leader>hr', gs.reset_hunk)
        vim.keymap.set('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
        vim.keymap.set('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
        vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk)
        vim.keymap.set('n', '<leader>hR', gs.reset_buffer)
    end
}
