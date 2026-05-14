local M = {}

-- terms[id] = { buf = bufnr }
-- The terminal process keeps running when the window is closed.
local terms = {}

local function float_config(id)
    local width  = math.floor(vim.o.columns * 0.9)
    local height = math.floor(vim.o.lines   * 0.85)
    return {
        relative   = "editor",
        width      = width,
        height     = height,
        row        = math.floor((vim.o.lines   - height) / 2),
        col        = math.floor((vim.o.columns - width)  / 2),
        style      = "minimal",
        border     = "rounded",
        title      = " Term " .. id .. " ",
        title_pos  = "center",
    }
end

function M.toggle(id)
    id = id or 1
    local t = terms[id]

    if t and vim.api.nvim_buf_is_valid(t.buf) then
        -- Check whether the buffer is currently shown in any window.
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == t.buf then
                -- Visible → hide (process keeps running).
                vim.api.nvim_win_close(win, false)
                return
            end
        end
        -- Hidden → re-open the float.
        vim.api.nvim_open_win(t.buf, true, float_config(id))
        vim.schedule(function() vim.cmd("startinsert") end)
        return
    end

    -- First open: create buffer, open float, start shell.
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(buf, true, float_config(id))
    vim.fn.termopen(vim.o.shell, {
        on_exit = function()
            terms[id] = nil
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) then
                    vim.api.nvim_buf_delete(buf, { force = true })
                end
            end)
        end,
    })
    terms[id] = { buf = buf }
    vim.schedule(function() vim.cmd("startinsert") end)
end

function M.setup()
    local map = vim.keymap.set

    -- <C-t>       toggle terminal 1 (the "primary" terminal)
    map("n", "<C-t>", function() M.toggle(1) end,
        { desc = "Toggle primary terminal", silent = true })

    -- <leader>1-5  named terminals, like tmux windows
    for i = 1, 5 do
        map("n", "<leader>" .. i, function() M.toggle(i) end,
            { desc = "Terminal " .. i, silent = true })
    end

    -- Per-terminal keymaps applied on every TermOpen.
    vim.api.nvim_create_autocmd("TermOpen", {
        callback = function()
            local o = { buffer = true, silent = true }
            -- <C-t> closes the float from both terminal and normal mode.
            map("t", "<C-t>", "<C-\\><C-N><cmd>close<CR>", o)
            map("n", "<C-t>", "<cmd>close<CR>", o)
            -- Clean look: no numbers or signs.
            vim.opt_local.number         = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn     = "no"
        end,
    })
end

return M
