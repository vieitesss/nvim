local M = {}

local binary = vim.fn.stdpath("config") .. "/bin/test-rpc"
local socket = "/tmp/test-rpc.sock"

local channel
local id = 0

local function on_data(data)
    vim.print("type: " .. type(data) .. "; data: " .. data)
end

---@return number?
local function rpc()
    if channel and channel > 0 then
        return channel
    end

    local job = vim.fn.jobstart(binary)
    if job == 0 then
        vim.notify(
            "invalid arguments to jobstart(): `" .. binary .. "` and `nil`",
            vim.log.levels.ERROR
        )
        return nil
    end
    if job == -1 then
        vim.notify(
            "binary `" .. binary .. "` is not executable",
            vim.log.levels.ERROR
        )
        return nil
    end

    if not channel then
        channel = vim.fn.sockconnect("pipe", socket, { on_data = on_data })
    end
    if channel == 0 then
        vim.notify(
            "an error occurred connecting to the socket " .. socket,
            vim.log.levels.ERROR
        )
        return nil
    end

    return channel
end

---@param method string The server method
---@param params string[] The method parameters
local function build_data(method, params)
    id = id + 1

    local msg = {
        jsonrpc = "2.0",
        id = id,
        method = method,
        params = params,
    }

    local body = vim.json.encode(msg)
    local data = "Content-Length: " .. #body .. "\r\n\r\n" .. body

    return data
end

M.multiply = function()
    local c = rpc()
    if not c then
        return
    end

    local data = build_data("Multiply", { "2", "3" })
    vim.api.nvim_chan_send(c, data)
end

return M
