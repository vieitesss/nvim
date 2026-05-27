---@alias callback_function fun(result: any, error: string)

local M = {
    _job = nil,
    ---@type table<number, callback_function>
    pending = {},
}

local binary = vim.fn.stdpath("config") .. "/bin/nvim-features"
local pid = tostring(vim.uv.os_getpid())
local socket = vim.uv.os_tmpdir() .. "/nvim-features-" .. pid .. ".sock"

local channel
local id = 0

local function on_data(_, data, _)
    for _, line in ipairs(data) do
        if line and line ~= "" then
            local decoded, info = pcall(vim.json.decode, line)
            if
                decoded
                and type(info) == "table"
                and info.id ~= nil
                and info.result ~= nil
            then
                local cb = M.pending[info.id]
                if cb then
                    cb(info.result, info.error)
                end
            else
                vim.notify(
                    string.format(
                        "could not call the callback function from id: %d",
                        info.id
                    ),
                    vim.log.levels.ERROR
                )
            end
        end
    end
end

-- Returns the channel id or nil
---@return number?
local function try_connect_socket()
    local attempts, timeout = 10, 20

    local function try_connect()
        local ok, chan =
            pcall(vim.fn.sockconnect, "pipe", socket, { on_data = on_data })
        if ok and chan > 0 then
            channel = chan
            return true
        end

        return false
    end

    local connected = vim.wait(attempts * timeout, try_connect, timeout)
    if connected then
        return channel
    end

    return nil
end

---@return number
local function start_job()
    local j = vim.fn.jobstart({ binary, socket }, {
        on_exit = function()
            channel = nil
            id = 0
        end,
    })
    if j == 0 then
        vim.notify(
            "invalid arguments to jobstart({" .. binary .. "," .. socket .. "})",
            vim.log.levels.ERROR
        )
    end
    if j == -1 then
        vim.notify(
            "binary `" .. binary .. "` is not executable",
            vim.log.levels.ERROR
        )
    end

    return j
end

--@param a number
--@param b number
-- M.multiply = function(a, b)
--     ensure_autocmd()
--     rpc(function()
--         local data = build_data("Multiply", { tostring(a), tostring(b) })
--         vim.api.nvim_chan_send(channel, data)
--     end)
-- end

---@param method string The server method
---@param params string[]? The method parameters
local function build_msg(method, params)
    params = params or {}

    local msg = {
        jsonrpc = "2.0",
        id = id,
        method = method,
        params = params,
    }

    local data = vim.json.encode(msg) .. "\n"

    return data
end
---@param method string Method to execute
---@param params string[] Parameters for the method
local function on_ready(method, params)
    local msg = build_msg(method, params)
    vim.api.nvim_chan_send(channel, msg)
end

---@param method string Method to execute
---@param params string[] Parameters for the method
---@param cb callback_function
M.rpc = function(method, params, cb)
    id = id + 1
    M.pending[id] = cb

    if channel and channel > 0 then
        on_ready(method, params)
        return
    end

    M._job = start_job()
    if M._job < 1 then
        return
    end

    if not channel or channel == 0 then
        channel = try_connect_socket()
    end
    if not channel or channel == 0 then
        vim.notify(
            "an error occurred connecting to the socket " .. socket,
            vim.log.levels.ERROR
        )
        if M._job and M._job > 0 then
            vim.fn.jobstop(M._job)
            M._job = nil
        end
        return
    end

    on_ready(method, params)
end

return M
