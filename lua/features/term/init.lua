local M = {}

---@alias Buffer { buf: number, name: string, cwd: string? }
---@alias TerminalsMap table<string, Buffer>

---@type TerminalsMap
local terms = {}

---@type number?
local current_win = nil

local map = vim.keymap.set

---@param title string
local function float_config(title)
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
        title = " " .. title .. " ",
        title_pos = "center",
    }
end

---@param cwd string
---@return string
local function cwd_name(cwd)
    local name = vim.fn.fnamemodify(cwd, ":t")
    if name == "" then
        return cwd
    end
    return name
end

---@return string
local function current_cwd()
    return vim.fn.getcwd()
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
    for _, t in pairs(terms) do
        if vim.api.nvim_buf_is_valid(t.buf) then
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if
                    vim.api.nvim_win_is_valid(win)
                    and vim.api.nvim_win_get_buf(win) == t.buf
                    and vim.api.nvim_win_get_config(win).relative ~= ""
                then
                    pcall(
                        vim.api.nvim_win_set_config,
                        win,
                        float_config(t.name)
                    )
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

---@param key string
---@param name string
---@param cwd string?
local function toggle_terminal(key, name, cwd)
    local t = terms[key]

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
        current_win = vim.api.nvim_open_win(t.buf, true, float_config(t.name))
        vim.schedule(function()
            vim.cmd("startinsert")
        end)

        return
    end

    -- First open
    close_terminal_window(current_win)
    local buf = vim.api.nvim_create_buf(false, true)
    current_win = vim.api.nvim_open_win(buf, true, float_config(name))
    vim.fn.jobstart(vim.o.shell, {
        term = true,
        cwd = cwd,
        on_exit = function()
            terms[key] = nil
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) then
                    vim.api.nvim_buf_delete(buf, { force = true })
                end
            end)
        end,
    })

    apply_terminal_keymaps(buf)
    terms[key] = { buf = buf, name = name, cwd = cwd }

    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"

    vim.schedule(function()
        vim.cmd("startinsert")
    end)
end

function M.toggle_default()
    local cwd = current_cwd()
    toggle_terminal("cwd:" .. cwd, cwd_name(cwd), cwd)
end

---@param id number|string
function M.toggle_scratch(id)
    toggle_terminal("scratch:" .. id, "Scratch " .. id, nil)
end

function M.setup()
    map(
        "n",
        "<C-t>",
        function()
            M.toggle_default()
        end,
        { desc = "Toggle terminal for current working directory", silent = true }
    )

    for i = 1, 9 do
        map("n", "<leader>" .. i, function()
            M.toggle_scratch(i)
        end, { desc = "Scratch terminal " .. i, silent = true })
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
