local M = {}

local binary = vim.fn.stdpath("config") .. "/bin/test-rpc"
local socket = "/tmp/test-rpc.sock"

local channel
local id = 0
local timeout = 50 -- ms

local function on_data(_, data, _)
    vim.print(data)
    local info = vim.json.decode(data[1])
    vim.print("result: " .. info.result)
end

---@return number?
local function try_connect()
    local times = 50
    local ok, chan

    while times > 0 do
        ok, chan =
            pcall(vim.fn.sockconnect, "pipe", socket, { on_data = on_data })
        if ok and chan > 0 then
            vim.print(50 - times)
            return chan
        end

        times = times - 1
        vim.uv.sleep(timeout)
    end

    return nil
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
        channel = try_connect()
    end
    if not channel then
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

    local data = vim.json.encode(msg) .. "\n"

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
