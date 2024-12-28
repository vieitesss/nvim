local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight yanked text
local highlight_group = augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank({ timeout = 170 })
    end,
    group = highlight_group,
    pattern = '*',
})

-- Open html automatically on save
autocmd('BufWritePost', {
    pattern = { "*.html", "*.css" },
    callback = function()
        local t = {}
        local output = vim.api.nvim_exec2("!pgrep Arc", { output = true }).output
        local _, count = output:gsub("%d+", function(c) table.insert(t, c) end)

        if count > 0 then
            -- vim.cmd("silent !osascript /Users/vieites/.config/nvim/lua/vt/scripts/RefreshBrowser.scpt")
        else
            vim.cmd("silent !open -a \"Brave\" %")
        end
    end
})

-- Set custom LSP hover window
autocmd({ "VimEnter", "VimResized" }, {
    desc = "Setup LSP hover window",
    callback = function()
        local width = math.floor(vim.o.columns * 0.8)
        local height = math.floor(vim.o.lines * 0.3)

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
            vim.lsp.handlers.hover, {
                border = "rounded",
                max_width = width,
                max_height = height,
            }
        )
    end
})

-- Save manually created folds automatically
local save_folds = augroup("Persistent Folds", { clear = true })

autocmd("BufWinLeave", {
    pattern = "*",
    callback = function()
        vim.cmd.mkview()
    end,
    group = save_folds
})

autocmd("BufWinEnter", {
    pattern = "*",
    callback = function()
        vim.cmd.loadview({ mods = { emsg_silent = true } })
    end,
    group = save_folds
})
