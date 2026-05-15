local M = {}

---@alias Buffer { buf: number }
---@alias TerminalsMap table<number, Buffer>

---@type TerminalsMap
local terms = {}

---@type number?
local current_win = nil

local map = vim.keymap.set

---@param id number
local function float_config(id)
    local width = math.floor(vim.o.columns * 0.9)
    local height = math.floor(vim.o.lines * 0.85)
    return {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
        title = " Term " .. id .. " ",
        title_pos = "center",
    }
end

---@param win number?
local function close_terminal_window(win)
    if not win or not vim.api.nvim_win_is_valid(win) then
        return
    end

    -- Terminal windows managed here are floating windows.
    -- Never close a normal editor window.
    if vim.api.nvim_win_get_config(win).relative == "" then
        return
    end

    vim.api.nvim_win_close(win, false)

    if current_win == win then
        current_win = nil
    end
end

function M.resize_open_terminals()
    for id, t in pairs(terms) do
        if vim.api.nvim_buf_is_valid(t.buf) then
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if
                    vim.api.nvim_win_is_valid(win)
                    and vim.api.nvim_win_get_buf(win) == t.buf
                    and vim.api.nvim_win_get_config(win).relative ~= ""
                then
                    pcall(vim.api.nvim_win_set_config, win, float_config(id))
                end
            end
        end
    end
end

---@param buf number
local function apply_terminal_keymaps(buf)
    local o = { buffer = buf, silent = true }

    map("t", "<C-,>", [[<C-\><C-N>]], o)
    map("n", "<C-t>", function()
        close_terminal_window(vim.api.nvim_get_current_win())
    end, o)
end

---@param id number?
function M.toggle(id)
    id = id or 1
    local t = terms[id]

    if t and vim.api.nvim_buf_is_valid(t.buf) then
        -- Check whether the buffer is currently shown in any window
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == t.buf then
                -- Already visible
                vim.api.nvim_win_close(win, false)
                current_win = nil
                return
            end
        end

        -- Not visible
        close_terminal_window(current_win)
        current_win = vim.api.nvim_open_win(t.buf, true, float_config(id))
        vim.schedule(function()
            vim.cmd("startinsert")
        end)

        return
    end

    -- First open
    close_terminal_window(current_win)
    local buf = vim.api.nvim_create_buf(false, true)
    current_win = vim.api.nvim_open_win(buf, true, float_config(id))
    vim.fn.jobstart(vim.o.shell, {
        term = true,
        on_exit = function()
            terms[id] = nil
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) then
                    vim.api.nvim_buf_delete(buf, { force = true })
                end
            end)
        end,
    })

    apply_terminal_keymaps(buf)
    terms[id] = { buf = buf }

    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"

    vim.schedule(function()
        vim.cmd("startinsert")
    end)
end

function M.setup()
    map("n", "<C-t>", function()
        M.toggle(1)
    end, { desc = "Toggle primary terminal", silent = true })

    for i = 1, 5 do
        map("n", "<leader>" .. i, function()
            M.toggle(i)
        end, { desc = "Terminal " .. i, silent = true })
    end

    local group =
        vim.api.nvim_create_augroup("UserFloatingTermResize", { clear = true })
    vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
        group = group,
        callback = function()
            M.resize_open_terminals()
        end,
    })
end

return M
