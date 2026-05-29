local core = require("features.cwd.core")

local M = {}

M.dir = vim.fn.stdpath("data") .. "/cwd-sessions/"
vim.fn.mkdir(M.dir, "p")

---@param cwd string
---@return string
local function session_path(cwd)
    return M.dir .. core.encode(core.normalize(cwd)) .. ".json"
end

---@param buf number
---@param opt string
---@return any
local function buf_option(buf, opt)
    local ok, value = pcall(function()
        return vim.api.nvim_get_option_value(opt, { buf = buf })
    end)
    return ok and value or nil
end

---@param buf number
---@return boolean
local function is_empty_buffer(buf)
    return vim.api.nvim_buf_is_valid(buf)
        and buf_option(buf, "buftype") == ""
        and buf_option(buf, "modified") ~= true
        and vim.api.nvim_buf_get_name(buf) == ""
        and vim.api.nvim_buf_line_count(buf) == 1
        and (vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "") == ""
end

---@param buf number
---@return string?
local function real_file_path(buf)
    if
        not vim.api.nvim_buf_is_valid(buf)
        or buf_option(buf, "buflisted") ~= true
        or buf_option(buf, "buftype") ~= ""
    then
        return nil
    end

    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" or name:match("^%a[%w+.-]*://") then
        return nil
    end

    local file_path = core.normalize(name)
    return core.is_directory(file_path) and nil or file_path
end

---@return { buf: number, path: string }[]
local function real_file_buffers()
    local buffers, seen = {}, {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local file_path = real_file_path(buf)
        if file_path and not seen[file_path] then
            seen[file_path] = true
            table.insert(buffers, { buf = buf, path = file_path })
        end
    end
    return buffers
end

---@param win number
---@return table?
local function capture_leaf(win)
    local file_path = vim.api.nvim_win_is_valid(win)
        and real_file_path(vim.api.nvim_win_get_buf(win))
    if not file_path then
        return nil
    end

    local cursor = vim.api.nvim_win_get_cursor(win)
    local ok, view = pcall(vim.api.nvim_win_call, win, vim.fn.winsaveview)
    return {
        type = "leaf",
        path = file_path,
        cursor = { line = cursor[1], col = cursor[2] },
        view = ok and view or nil,
    }
end

---@param node table
---@return table?
local function capture_layout_node(node)
    if node[1] == "leaf" then
        return capture_leaf(node[2])
    end

    local children = {}
    for _, child in ipairs(node[2] or {}) do
        local captured = capture_layout_node(child)
        if captured then
            table.insert(children, captured)
        end
    end

    if #children == 0 then
        return nil
    end
    return #children == 1 and children[1]
        or { type = node[1], children = children }
end

---@param cwd string
function M.save(cwd)
    local paths = {}
    for _, item in ipairs(real_file_buffers()) do
        table.insert(paths, item.path)
    end

    local ok, encoded = pcall(function()
        return vim.json.encode({
            cwd = core.normalize(cwd),
            buffers = paths,
            current = real_file_path(vim.api.nvim_get_current_buf()),
            layout = capture_layout_node(vim.fn.winlayout()),
        })
    end)
    if not ok then
        vim.notify("Cwd: could not encode session", vim.log.levels.WARN)
        return
    end

    local write_ok, err = pcall(function()
        vim.fn.writefile({ encoded }, session_path(cwd))
    end)
    if not write_ok then
        vim.notify(
            "Cwd: could not save session: " .. tostring(err),
            vim.log.levels.WARN
        )
    end
end

---@param cwd string
---@return table?
local function load(cwd)
    local file_path = session_path(cwd)
    if vim.fn.filereadable(file_path) ~= 1 then
        return nil
    end

    local ok, lines = pcall(vim.fn.readfile, file_path)
    if not ok then
        return nil
    end

    ok, lines = pcall(vim.json.decode, table.concat(lines, "\n"))
    return ok and type(lines) == "table" and lines or nil
end

---@param buffers { buf: number, path: string }[]
local function close_real_file_buffers(buffers)
    local real_bufs, file_wins = {}, {}
    for _, item in ipairs(buffers) do
        real_bufs[item.buf] = true
    end
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if
            vim.api.nvim_win_is_valid(win)
            and real_bufs[vim.api.nvim_win_get_buf(win)]
        then
            table.insert(file_wins, win)
        end
    end

    local placeholder = #file_wins > 0 and vim.api.nvim_create_buf(false, false)
        or nil
    if placeholder then
        for _, win in ipairs(file_wins) do
            if vim.api.nvim_win_is_valid(win) then
                pcall(vim.api.nvim_win_set_buf, win, placeholder)
            end
        end
    end

    for _, item in ipairs(buffers) do
        local ok, err = pcall(function()
            if vim.api.nvim_buf_is_valid(item.buf) then
                vim.api.nvim_buf_delete(item.buf, { force = false })
            end
        end)
        if not ok then
            vim.notify(
                "Cwd: could not close "
                    .. vim.fn.fnamemodify(item.path, ":~")
                    .. ": "
                    .. tostring(err),
                vim.log.levels.WARN
            )
        end
    end

    local keep_win = nil
    local current = vim.api.nvim_get_current_win()
    for _, win in ipairs(file_wins) do
        if
            vim.api.nvim_win_is_valid(win)
            and is_empty_buffer(vim.api.nvim_win_get_buf(win))
        then
            if win == current then
                keep_win = win
                break
            end
            keep_win = keep_win or win
        end
    end

    for _, win in ipairs(file_wins) do
        if #vim.api.nvim_tabpage_list_wins(0) <= 1 then
            return
        end
        if
            win ~= keep_win
            and vim.api.nvim_win_is_valid(win)
            and is_empty_buffer(vim.api.nvim_win_get_buf(win))
        then
            pcall(vim.api.nvim_win_close, win, false)
        end
    end
end

---@param file_path string
---@return number?
local function load_listed_buffer(file_path)
    local buf = vim.fn.bufadd(file_path)
    if buf <= 0 then
        return nil
    end
    pcall(vim.fn.bufload, buf)
    pcall(function()
        vim.api.nvim_set_option_value("buflisted", true, { buf = buf })
    end)
    return buf
end

---@param buf number
---@return boolean
local function is_cwd_fallback_buffer(buf)
    local ok, value = pcall(vim.api.nvim_buf_get_var, buf, "cwd_fallback")
    return ok and value == true
end

local function close_cwd_fallback_buffers()
    local buffers, seen, fallback_wins = {}, {}, {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_is_valid(win)
            and vim.api.nvim_win_get_buf(win)
        if buf and is_cwd_fallback_buffer(buf) then
            if not seen[buf] then
                seen[buf] = true
                table.insert(buffers, buf)
            end
            table.insert(fallback_wins, win)
        end
    end

    local keep_win = nil
    local current = vim.api.nvim_get_current_win()
    for _, win in ipairs(fallback_wins) do
        if vim.api.nvim_win_is_valid(win) then
            if win == current then
                keep_win = win
                break
            end
            keep_win = keep_win or win
        end
    end

    if keep_win and vim.api.nvim_win_is_valid(keep_win) then
        local placeholder = vim.api.nvim_create_buf(false, false)
        pcall(vim.api.nvim_win_set_buf, keep_win, placeholder)
    end

    for _, win in ipairs(fallback_wins) do
        if
            win ~= keep_win
            and #vim.api.nvim_tabpage_list_wins(0) > 1
            and vim.api.nvim_win_is_valid(win)
        then
            pcall(vim.api.nvim_win_close, win, false)
        end
    end

    for _, buf in ipairs(buffers) do
        pcall(function()
            if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end)
    end
end

---@return number
local function ensure_anchor_window()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if
            vim.api.nvim_win_is_valid(win)
            and is_empty_buffer(vim.api.nvim_win_get_buf(win))
        then
            return win
        end
    end
    vim.cmd("silent botright new")
    return vim.api.nvim_get_current_win()
end

---@param win number
---@param file_path string
---@return boolean
local function edit_file_in_window(win, file_path)
    if not vim.api.nvim_win_is_valid(win) then
        return false
    end

    local buf = load_listed_buffer(file_path)
    if buf and pcall(vim.api.nvim_win_set_buf, win, buf) then
        return true
    end

    vim.notify(
        "Cwd: could not open " .. vim.fn.fnamemodify(file_path, ":~"),
        vim.log.levels.WARN
    )
    return false
end

---@param win number
---@param layout_type string
---@return number?
local function split_window(win, layout_type)
    if not vim.api.nvim_win_is_valid(win) then
        return nil
    end

    local buf = vim.api.nvim_win_get_buf(win)
    local ok, split = pcall(vim.api.nvim_open_win, buf, false, {
        win = win,
        split = layout_type == "row" and "right" or "below",
    })
    if ok then
        return split
    end

    return vim.api.nvim_win_call(win, function()
        vim.cmd(
            layout_type == "row" and "silent rightbelow vsplit"
                or "silent rightbelow split"
        )
        return vim.api.nvim_get_current_win()
    end)
end

---@param node table
---@param win number
---@param opened table<string, number>
local function restore_layout_node(node, win, opened)
    if node.type == "leaf" then
        if
            type(node.path) ~= "string"
            or not edit_file_in_window(win, node.path)
        then
            return
        end

        opened[node.path] = win
        if type(node.view) == "table" then
            pcall(vim.api.nvim_win_call, win, function()
                vim.fn.winrestview(node.view)
            end)
        elseif type(node.cursor) == "table" and node.cursor.line then
            pcall(function()
                vim.api.nvim_win_set_cursor(
                    win,
                    { node.cursor.line, node.cursor.col or 0 }
                )
            end)
        end
        return
    end

    local children = type(node.children) == "table" and node.children or {}
    local wins = { win }
    for i = 2, #children do
        wins[i] = split_window(wins[i - 1], node.type)
    end
    for i, child in ipairs(children) do
        if wins[i] then
            restore_layout_node(child, wins[i], opened)
        end
    end
end

local function open_empty_fallback_buffer()
    local win = ensure_anchor_window()
    local buf = vim.api.nvim_create_buf(false, false)
    pcall(vim.api.nvim_buf_set_var, buf, "cwd_fallback", true)
    if vim.api.nvim_win_is_valid(win) then
        pcall(vim.api.nvim_win_set_buf, win, buf)
        vim.api.nvim_set_current_win(win)
    end
end

---@param dir string
function M.restore(dir)
    local session = load(dir)
    local buffers = session and session.buffers
    if type(buffers) ~= "table" or #buffers == 0 then
        open_empty_fallback_buffer()
        return
    end

    local opened = {}
    assert(session ~= nil)
    if type(session.layout) == "table" then
        restore_layout_node(session.layout, ensure_anchor_window(), opened)
    else
        local first = type(session.current) == "string" and session.current
            or buffers[1]
        local anchor = ensure_anchor_window()
        if type(first) == "string" and edit_file_in_window(anchor, first) then
            opened[first] = anchor
        end
    end

    for _, file_path in ipairs(buffers) do
        if type(file_path) == "string" and not opened[file_path] then
            load_listed_buffer(file_path)
        end
    end

    local current = session.current
    if
        type(current) == "string"
        and opened[current]
        and vim.api.nvim_win_is_valid(opened[current])
    then
        vim.api.nvim_set_current_win(opened[current])
    end
    pcall(function()
        vim.cmd("silent wincmd =")
    end)
end

---@return string[]
function M.modified_buffers()
    local shown = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
            vim.api.nvim_buf_is_valid(buf)
            and buf_option(buf, "buflisted") == true
            and buf_option(buf, "modified") == true
            and buf_option(buf, "buftype") == ""
        then
            local name = vim.api.nvim_buf_get_name(buf)
            local file_path = name ~= "" and core.normalize(name) or nil
            if
                file_path
                and not name:match("^%a[%w+.-]*://")
                and not core.is_directory(file_path)
            then
                table.insert(
                    shown,
                    #shown >= 8 and "…" or vim.fn.fnamemodify(file_path, ":~")
                )
                if #shown > 8 then
                    break
                end
            end
        end
    end

    return shown
end

---@return { buf: number, path: string }[]
function M.real_file_buffers()
    return real_file_buffers()
end

---@param buffers { buf: number, path: string }[]
function M.close_real_file_buffers(buffers)
    close_real_file_buffers(buffers)
end

function M.close_cwd_fallback_buffers()
    close_cwd_fallback_buffers()
end

return M
