---@alias callback_function fun(result: any, error: string?)

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

---@param msg string
local function log_error(msg)
    vim.notify(msg, vim.log.levels.ERROR)
end

local function error_message(err)
    if err == nil or err == "" then
        return nil
    end
    if type(err) == "table" then
        return tostring(err.message or vim.inspect(err))
    end
    return tostring(err)
end

local function on_data(_, data, _)
    for _, line in ipairs(data) do
        if line and line ~= "" then
            local decoded, info = pcall(vim.json.decode, line)
            if not decoded then
                log_error(string.format("could not decode line = %s", line))
                return
            end
            if type(info) == "table" and info.id ~= nil then
                local cb = M.pending[info.id]
                M.pending[info.id] = nil
                if cb then
                    cb(info.result, error_message(info.error))
                else
                    log_error(
                        string.format(
                            "could not call the callback function from id: %d",
                            info.id
                        )
                    )
                end
                return
            end
            log_error("`info` is not a table or info.id is nil")
        end
    end
end

-- Returns the channel id or nil
---@return number?
local function try_connect_socket()
    local attempts, timeout = 100, 20

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

---@param method string The server method
---@param params any The method parameters
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
---@param params any Parameters for the method
local function on_ready(method, params)
    local msg = build_msg(method, params)
    vim.api.nvim_chan_send(channel, msg)
end

---@param method string Method to execute
---@param params any Parameters for the method
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
        local msg = "could not start RPC server"
        M.pending[id] = nil
        cb(nil, msg)
        return
    end

    if not channel or channel == 0 then
        channel = try_connect_socket()
    end
    if not channel or channel == 0 then
        local msg = "an error occurred connecting to the socket " .. socket
        M.pending[id] = nil
        cb(nil, msg)
        if M._job and M._job > 0 then
            vim.fn.jobstop(M._job)
            M._job = nil
        end
        return
    end

    on_ready(method, params)
end

return M
