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
M.real_file_buffers = function()
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

---@param cwd string
function M.save(cwd)
    local paths = {}
    for _, item in ipairs(M.real_file_buffers()) do
        table.insert(paths, item.path)
    end

    local ok, encoded = pcall(function()
        return vim.json.encode({
            buffers = paths,
            current = real_file_path(vim.api.nvim_get_current_buf()),
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
M.close_real_file_buffers = function(buffers)
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

local function open_empty_buffer()
    pcall(function(c)
        vim.cmd(c)
    end, "enew")
end

---@param file_path string
---@return boolean
local function edit_file(file_path)
    local buf = load_listed_buffer(file_path)
    if buf and pcall(vim.api.nvim_set_current_buf, buf) then
        return true
    end

    vim.notify(
        "Cwd: could not open " .. vim.fn.fnamemodify(file_path, ":~"),
        vim.log.levels.WARN
    )
    return false
end

---@param dir string
function M.restore(dir)
    local session = load(dir)
    local buffers = session and session.buffers
    if type(buffers) ~= "table" or #buffers == 0 then
        open_empty_buffer()
        return
    end

    local current = buffers[1]
    if session and type(session.current) == "string" then
        current = session.current
    end
    local opened = type(current) == "string" and edit_file(current)

    for _, file_path in ipairs(buffers) do
        if type(file_path) == "string" and file_path ~= current then
            load_listed_buffer(file_path)
        end
    end

    if not opened then
        open_empty_buffer()
    end
end

---@return string[]
M.modified_buffers = function()
    local shown = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local file_path = buf_option(buf, "modified") == true
                and real_file_path(buf)
            or nil
        if file_path then
            table.insert(
                shown,
                #shown >= 8 and "…" or vim.fn.fnamemodify(file_path, ":~")
            )
            if #shown > 8 then
                break
            end
        end
    end

    return shown
end

return M
