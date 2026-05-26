local M = {}

local binary = vim.fn.stdpath("config") .. "/bin/nvim-features"
local pid = tostring(vim.uv.os_getpid())
local socket = "/tmp/nvim-features-" .. pid .. ".sock"

local job
local channel
local id = 0

-- Returns the channel id or nil
---@return number?
local function try_connect_socket()
    local attempts, timeout = 10, 20

    local function try_connect()
        local ok, chan = pcall(vim.fn.sockconnect, "pipe", socket, {
            on_data = function(_, data, _)
                vim.print(data)
                local info = vim.json.decode(data[1])
                vim.print("result: " .. info.result)
            end,
        })
        if ok and chan > 0 then
            channel = chan
            vim.print(attempts)
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
    local j = vim.fn.jobstart({ binary, pid }, {
        on_exit = function()
            channel = nil
            id = 0
        end,
    })
    if j == 0 then
        vim.notify(
            "invalid arguments to jobstart(): `" .. binary .. "` and `nil`",
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

---@param on_ready function
local function rpc(on_ready)
    if channel and channel > 0 then
        on_ready()
        return
    end

    job = start_job()
    if job < 1 then
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
        return
    end

    on_ready()
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

local ag = vim.api.nvim_create_augroup("NeovimFeatures", {})

local function ensure_autocmd()
    vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
        pattern = { "*" },
        group = ag,
        callback = function(_)
            if job and job > 0 then
                vim.fn.jobstop(job)
            end
        end,
    })
end

---@param a number
---@param b number
M.multiply = function(a, b)
    ensure_autocmd()
    rpc(function()
        local data = build_data("Multiply", { tostring(a), tostring(b) })
        vim.api.nvim_chan_send(channel, data)
    end)
end

return M
