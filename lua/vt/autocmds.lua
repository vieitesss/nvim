-- Latex autocmd save and compile .tex
-- vim.api.nvim_create_autocmd("BufWritePost", {
--     pattern = "*.tex",
--     callback = function()
--         local file = vim.fn.expand("%:p")
--         vim.cmd(":silent ! latexmk -cd -f -shell-escape -pdf " .. file)
--         vim.cmd(":silent ! latexmk -c")
--         local pgrep = vim.api.nvim_exec2("silent ! pgrep \"Skim\"", { output = true }).output
--         local _, count = pgrep:gsub("%d%d+", function() end)
--         -- Opens the pdf viewer only if it is not opened
--         -- Otherwise, the viewer reloads itself if the pdf has changed
--         if count == 0 then
--             local filename = vim.fn.expand("%:p:r")
--             vim.cmd(":silent ! osascript -e 'tell application \"Finder\" to open file \"" .. filename .. ".pdf\" as POSIX file'")
--         end
--     end
-- })

-- Hide cmd input prompt when finished recording macro
-- vim.api.nvim_create_autocmd("RecordingLeave", {
--     pattern = "*",
--     callback = function()
--         vim.api.nvim_exec2("set cmdheight=0", {})
--     end
-- })

-- Show cmd input prompt where recording macro
-- vim.api.nvim_create_autocmd("RecordingEnter", {
--     pattern = "*",
--     callback = function()
--         vim.api.nvim_exec2("set cmdheight=1", {})
--     end
-- })

-- Highlight yanked text
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank({ timeout = 170 })
    end,
    group = highlight_group,
    pattern = '*',
})

-- Open html automatically on save in Chrome
vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = { "*.html", "*.css" },
    callback = function() 
        local t = {}
        local output = vim.api.nvim_exec2("!pgrep Brave", { output = true }).output
        local _, count = output:gsub("%d+", function(c) table.insert(t, c) end)

        if count > 0 then
            -- vim.cmd("silent !osascript /Users/vieites/.config/nvim/lua/vt/scripts/RefreshBrowser.scpt")
        else
            vim.cmd("silent !open -a \"Brave\" %")
        end

    end
})
